# Day 29/40 Kubernetes Volume Simplified | Persistent Volume, Persistent Volume Claim & Storage Class

## Check out the video below for Day29 👇

[![Day 29/40 Kubernetes Volume Simplified | Persistent Volume, Persistent Volume Claim & Storage Class ](https://img.youtube.com/vi/2NzYX8_lX_0/sddefault.jpg)](https://youtu.be/2NzYX8_lX_0)

### How they are related to each other

![image](https://github.com/user-attachments/assets/dfe93e1e-e5d2-447a-a3da-ee2391b1b73a)

### Example of a non-persistent volume, type: emptyDir

An `emptyDir` volume is created when the pod starts and deleted when the pod is removed. It survives container restarts, and all the containers in the pod can share it.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-storage
      mountPath: /data/redis
  volumes:
  - name: redis-storage
    emptyDir: {}
```

### Sample pv used in the demo

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: standard
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/home/ubuntu/day28-storage-k8s"
```

### Sample PVC used in the demo

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

### Sample pod yaml used in the demo

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
```

### How a PVC finds a PV

A PVC binds to a PV only when all of the below match:
- The `storageClassName` is the same on both (or empty on both)
- The PV supports the access mode that the PVC asks for
- The capacity of the PV is equal to or bigger than the request of the PVC

One PV binds to exactly one PVC. In the samples above the PVC asks for 500Mi and gets the whole 1Gi PV. If no PV matches, the PVC stays in `Pending`.

### Access modes

| Mode | Short form | Meaning |
|---|---|---|
| ReadWriteOnce | RWO | Mounted read-write by a single node. Several pods on that node can use it |
| ReadOnlyMany | ROX | Mounted read-only by many nodes |
| ReadWriteMany | RWX | Mounted read-write by many nodes |
| ReadWriteOncePod | RWOP | Mounted read-write by a single pod in the whole cluster |

### Reclaim policies

The `persistentVolumeReclaimPolicy` of a PV decides what happens to the volume after its PVC is deleted.

- `Retain`: the PV and its data are kept. The PV moves to the `Released` status and cannot be claimed again until an admin cleans it up. This is the default for PVs that you create by hand.
- `Delete`: the PV and the storage behind it are deleted. This is the default for dynamically provisioned volumes.
- `Recycle`: deprecated. Do not use it.

### Volume modes

- `Filesystem` (default): the volume is formatted and mounted as a directory in the pod.
- `Block`: the volume is given to the pod as a raw block device.

### Storage classes

With a StorageClass, you do not create PVs by hand. When a PVC names a StorageClass, the provisioner of that class creates a matching PV on demand. This is called dynamic provisioning and is covered in detail in the [Day52](../Day52-StorageClass-DynamicProvisioning) folder.

### Useful commands

```bash
kubectl get pv,pvc
kubectl describe pvc task-pv-claim
kubectl get sc

# change the reclaim policy of an existing PV
kubectl patch pv task-pv-volume -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

> Note: A `hostPath` volume stores the data on the disk of one node. It is fine for learning on a single node or for the exam, but if the pod is rescheduled to another node it will not find its data there.
