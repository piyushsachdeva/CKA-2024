# Kubernetes Storage Classes & Dynamic Provisioning Assignment

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

### Default Storage Class
A **Default Storage Class** is the storage class that Kubernetes automatically uses when:
- A PVC is created WITHOUT specifying a `storageClassName`
- No explicit storage class is mentioned in the PVC spec

**Benefits of Default Storage Class:**
- **Simplifies Development**: Developers don't need to specify storage class every time
- **Consistent Behavior**: Ensures predictable storage provisioning across the cluster
- **Reduces Errors**: Prevents PVCs from staying in Pending state due to missing storage class

**How to Identify Default Storage Class:**
```bash
# Look for the storage class with (default) annotation
kubectl get storageclass
```

Output example:
```
NAME                     PROVISIONER            RECLAIMPOLICY   VOLUMEBINDINGMODE
cost-effective          kubernetes.io/gce-pd   Delete          Immediate
high-performance        kubernetes.io/gce-pd   Retain          WaitForFirstConsumer
standard (default)      kubernetes.io/gce-pd   Delete          Immediate
```

---

## 🛠️ Hands-On Demo

### Prerequisites
- Kubernetes cluster (minikube, kind, or cloud cluster)
- kubectl configured
- Basic understanding of PVs and PVCs

### Demo 1: High-Performance Storage Class (Production)

This storage class is designed for production workloads requiring high IOPS and low latency.

```yaml
# high-performance-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: high-performance
  labels:
    tier: production
    performance: high
provisioner: kubernetes.io/gce-pd  # Google Cloud Persistent Disk provisioner
parameters:
  type: pd-ssd                      # High-performance SSD
  zones: us-central1-a,us-central1-b,us-central1-c
  replication-type: regional-pd     # Regional replication for HA
  fsType: ext4
reclaimPolicy: Retain              # Keep data after PVC deletion
allowVolumeExpansion: true         # Allow volume expansion
volumeBindingMode: WaitForFirstConsumer
```

### Demo 2: Cost-Effective Storage Class (Development)

This storage class is optimized for development environments where cost is more important than performance.

```yaml
# cost-effective-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cost-effective
  labels:
    tier: development
    performance: standard
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard                 # Standard HDD (cheaper)
  zones: us-central1-a
  replication-type: none           # No replication for cost savings
  fsType: ext4
reclaimPolicy: Delete              # Delete data after PVC deletion
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

### Step-by-Step Implementation

#### Step 1: Create Storage Classes
```bash
# Apply both storage classes
kubectl apply -f high-performance-sc.yaml
kubectl apply -f cost-effective-sc.yaml

# Verify creation
kubectl get storageclass

# Make cost-effective storage class the default for development clusters
kubectl patch storageclass cost-effective -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Verify default storage class (should show "default" next to cost-effective)
kubectl get storageclass
```

#### Step 2: Create PVCs Using Different Storage Classes

**Production PVC (High-Performance):**
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
  storageClassName: high-performance
  resources:
    requests:
      storage: 50Gi
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
      storage: 10Gi
```

**Alternative Dev PVC (Explicitly Using Cost-Effective):**
```yaml
# dev-pvc-explicit.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dev-app-storage-explicit
  labels:
    environment: development
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: cost-effective  # Explicitly specified
  resources:
    requests:
      storage: 10Gi
```

#### Step 3: Apply PVCs and Observe Dynamic Provisioning
```bash
# Create PVCs
kubectl apply -f prod-pvc.yaml
kubectl apply -f dev-pvc.yaml

# Watch dynamic provisioning in action
kubectl get pvc -w
kubectl get pv
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
```

**Happy Learning! 🚀**

Don't forget to like, subscribe, and hit the notification bell for more Kubernetes content!
