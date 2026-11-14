# Day 52 - Kubernetes Storage Classes & Dynamic Provisioning Assignment

## 📚 Key Concepts

### What is Storage Provisioning?
Storage provisioning is the process of creating storage volumes for your applications in Kubernetes.

### Static vs Dynamic Provisioning

#### Static Provisioning
- **Manual Process**: Admin creates storage volumes manually
- **Pre-created**: Volumes exist before pods need them
- **Limited Flexibility**: Fixed size and configuration
- **Example**: Admin creates 10 PVs of 5GB each, hoping applications will use them


#### Dynamic Provisioning
- **Automatic Process**: Storage created when requested
- **On-Demand**: Volumes created when PVC is submitted
- **Flexible**: Size and configuration based on requirements
- **Efficient**: No pre-allocation or waste


### What is a Storage Class?
A Storage Class is like a "template" that defines:
- **What type** of storage to create (SSD, HDD, NFS, etc.)
- **How** to create it (which provisioner to use)
- **Configuration** parameters (performance, durability, etc.)

Think of it as ordering from a restaurant menu - you specify what you want, and the kitchen (provisioner) prepares it for you.

### Fields of a Storage Class

| Field | Meaning |
|---|---|
| `provisioner` | The CSI driver (or other provisioner) that creates the volumes. It must be installed in the cluster |
| `parameters` | Settings that are passed to the provisioner. They are different for every provisioner |
| `reclaimPolicy` | What happens to the volume when the PVC is deleted: `Delete` (default) or `Retain` |
| `volumeBindingMode` | `Immediate` creates the volume as soon as the PVC is created. `WaitForFirstConsumer` waits until a pod uses the PVC, so that the volume is created on the node or in the zone where the pod is scheduled |
| `allowVolumeExpansion` | If `true`, you can make a volume bigger later by editing the size in the PVC |

The `provisioner`, `parameters`, `reclaimPolicy` and `volumeBindingMode` of a StorageClass cannot be changed after it is created. To change them, you delete the StorageClass and create it again. Existing PVs are not affected by that.

### Default Storage Class
A **Default Storage Class** is the storage class that Kubernetes automatically uses when:
- A PVC is created WITHOUT specifying a `storageClassName`
- No explicit storage class is mentioned in the PVC spec

**Benefits of Default Storage Class:**
- **Simplifies Development**: Developers don't need to specify storage class every time
- **Consistent Behavior**: Ensures predictable storage provisioning across the cluster
- **Reduces Errors**: Prevents PVCs from staying in Pending state due to missing storage class

A cluster should have exactly one default StorageClass. When you make a new class the default, remove the annotation from the old one.

**How to Identify Default Storage Class:**
```bash
# Look for the storage class with (default) next to its name
kubectl get storageclass
```

Output example:
```
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  5d
```

> Note: A PVC with `storageClassName: ""` (an empty string) is different from a PVC without the field. The empty string means "do not use any StorageClass, bind only to a PV that has no class". This is used for static provisioning, as in the Day 29 task.

---

## 🛠️ Hands-On Demo

> Note: The video shows StorageClasses with the provisioner `kubernetes.io/gce-pd`. That is the old in-tree Google Cloud driver, which has been removed from Kubernetes. Cloud storage is now provided through CSI drivers (for example `pd.csi.storage.gke.io` on GKE and `ebs.csi.aws.com` on EKS), and those StorageClasses only work on that cloud. So that you can run this demo on any cluster, including kind and kubeadm, the steps below use the Rancher local-path provisioner. The same StorageClasses for GKE are given at the end for reference.

### Prerequisites
- Kubernetes cluster (minikube, kind, kubeadm or a cloud cluster)
- kubectl configured
- Basic understanding of PVs and PVCs

### Step 1: Install a provisioner

kind already ships with the local-path provisioner and a default StorageClass named `standard`, so on kind you can skip this step. On a kubeadm cluster there is no provisioner, so install one:

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl get pods -n local-path-storage
kubectl get storageclass
```

This creates a StorageClass named `local-path` with the provisioner `rancher.io/local-path`. It creates a directory on the node for every volume. It is meant for learning and testing, not for production data.

### Step 2: Create two Storage Classes

A storage class for data that must be kept after the PVC is deleted:

```yaml
# retain-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: retain-storage
  labels:
    tier: production
provisioner: rancher.io/local-path
reclaimPolicy: Retain              # Keep data after PVC deletion
volumeBindingMode: WaitForFirstConsumer
```

A storage class for development, where the data can be thrown away:

```yaml
# dev-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: dev-storage
  labels:
    tier: development
provisioner: rancher.io/local-path
reclaimPolicy: Delete              # Delete data after PVC deletion
volumeBindingMode: WaitForFirstConsumer
```

```bash
# Apply both storage classes
kubectl apply -f retain-sc.yaml
kubectl apply -f dev-sc.yaml

# Verify creation
kubectl get storageclass
```

### Step 3: Change the default Storage Class

```bash
# Find the current default class, if there is one (standard on kind)
kubectl get storageclass

# Remove the default annotation from the current default class
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Make dev-storage the default
kubectl patch storageclass dev-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Verify default storage class (should show "default" next to dev-storage only)
kubectl get storageclass
```

### Step 4: Create PVCs Using Different Storage Classes

**Production PVC (explicit storage class):**
```yaml
# prod-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prod-app-storage
  labels:
    environment: production
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: retain-storage
  resources:
    requests:
      storage: 1Gi
```

**Development PVC (Using Default Storage Class):**
```yaml
# dev-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dev-app-storage
  labels:
    environment: development
spec:
  accessModes:
    - ReadWriteOnce
  # Notice: No storageClassName specified - will use default
  resources:
    requests:
      storage: 500Mi
```

```bash
# Create PVCs
kubectl apply -f prod-pvc.yaml
kubectl apply -f dev-pvc.yaml

kubectl get pvc
kubectl get pv
```

Both the PVCs stay in `Pending` and no PV exists yet. This is because of `volumeBindingMode: WaitForFirstConsumer`. `kubectl describe pvc dev-app-storage` shows the event `waiting for first consumer to be created before binding`.

### Step 5: Use the PVCs in a Pod and Observe Dynamic Provisioning

```yaml
# storage-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
spec:
  containers:
  - name: app
    image: busybox:1.28
    command: ["sh", "-c", "echo hello > /prod/file.txt && sleep 3600"]
    volumeMounts:
    - name: prod
      mountPath: /prod
    - name: dev
      mountPath: /dev-data
  volumes:
  - name: prod
    persistentVolumeClaim:
      claimName: prod-app-storage
  - name: dev
    persistentVolumeClaim:
      claimName: dev-app-storage
```

```bash
kubectl apply -f storage-pod.yaml

# Watch dynamic provisioning in action
kubectl get pvc -w
kubectl get pv
```

Now both the PVCs are `Bound`, and two PVs were created for you by the provisioner, one per PVC. Look at the `RECLAIM POLICY` and `STORAGECLASS` columns of the PVs.

### Step 6: See the reclaim policy at work

```bash
kubectl delete pod storage-pod
kubectl delete pvc prod-app-storage dev-app-storage
kubectl get pv
```

The PV that was created through `dev-storage` is gone. The PV that was created through `retain-storage` is still there with the status `Released`. Its data is kept, and an admin has to delete or reuse it by hand.

### Step 7: Clean Up

```bash
kubectl get pv
kubectl delete pv <name-of-the-released-pv>
kubectl delete sc retain-storage dev-storage

# on kind, make standard the default again
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

---

## Volume expansion

If the StorageClass has `allowVolumeExpansion: true` and the CSI driver supports it, you can make a volume bigger by raising the size in the PVC. You cannot make a volume smaller.

```bash
kubectl patch pvc <pvc-name> -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
kubectl describe pvc <pvc-name>
```

The local-path provisioner used above does not support expansion. Cloud CSI drivers do.

## Reference: Storage Classes on a cloud provider (GKE)

These are the two StorageClasses from the video, written for the current GKE CSI driver. They work only on a GKE cluster.

```yaml
# high-performance-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: high-performance
  labels:
    tier: production
    performance: high
provisioner: pd.csi.storage.gke.io   # Google Cloud Persistent Disk CSI driver
parameters:
  type: pd-ssd                       # High-performance SSD
  replication-type: regional-pd      # Regional replication for HA
reclaimPolicy: Retain                # Keep data after PVC deletion
allowVolumeExpansion: true           # Allow volume expansion
volumeBindingMode: WaitForFirstConsumer
---
# cost-effective-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cost-effective
  labels:
    tier: development
    performance: standard
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-standard                  # Standard HDD (cheaper)
  replication-type: none             # No replication for cost savings
reclaimPolicy: Delete                # Delete data after PVC deletion
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

### Important Commands to Remember
```bash
# List all storage classes
kubectl get sc

# Describe storage class details
kubectl describe sc <storage-class-name>

# Set storage class as default
kubectl patch storageclass <storage-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Remove default annotation from storage class
kubectl patch storageclass <storage-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Check which storage class is default
kubectl get storageclass | grep "(default)"

# Check PVC status
kubectl get pvc

# Troubleshoot PVC issues
kubectl describe pvc <pvc-name>

# View storage class parameters
kubectl get sc <storage-class-name> -o yaml

# List the CSI drivers installed in the cluster
kubectl get csidrivers
```
