# Day 13/40 - static pods, manual scheduling, labels, and selectors in Kubernetes 📘🚀

## Check out the video below for Day13 👇

[![Day 13/40 - static pods, manual scheduling, labels, and selectors in Kubernetes](https://img.youtube.com/vi/6eGf7_VSbrQ/sddefault.jpg)](https://youtu.be/6eGf7_VSbrQ)


Welcome to the quick reference guide for our Kubernetes Labels, Selectors, and Static Pods video! This guide will be handy as you dive deeper into Kubernetes, especially if you're starting. Let's explore these concepts in detail:

---

## 📌 Labels and Selectors in Kubernetes

### Labels 🏷️
Labels are key-value pairs attached to Kubernetes objects like pods, services, and deployments. They help organize and group resources based on criteria that make sense to you.

**Examples of Labels:**
- `environment: production`
- `type: backend`
- `tier: frontend`
- `application: my-app`

### Selectors 🔍
Selectors filter Kubernetes objects based on their labels. This is incredibly useful for querying and managing a subset of objects that meet specific criteria.

**Common Usage:**
- **Pods**: `kubectl get pods --selector app=my-app` (short form: `-l app=my-app`). You can also use set-based selectors, for example `kubectl get pods -l 'env in (dev,prod)'`, and `kubectl get pods --show-labels` to list the labels
- **Deployments**: Used to filter the pods managed by the deployment.
- **Services**: Filter the pods to which the service routes traffic.

### Labels vs. Namespaces 🌍
- **Labels**: Organize resources within the same or across namespaces.
- **Namespaces**: Provide a way to isolate resources from each other within a cluster.

### Annotations 📝
Annotations are similar to labels but attach non-identifying metadata to objects. For example, recording the release version of an application for information purposes or last applied configuration details etc.

---

## 🛠️ Static Pods

Static Pods are special types of pods managed directly by the `kubelet` on each node rather than through the Kubernetes API server.

### Key Characteristics of Static Pods:
- **Not Managed by the Scheduler**: Unlike deployments or replicasets, the Kubernetes scheduler does not manage static pods.
- **Defined on the Node**: Configuration files for static pods are placed directly on the node's file system, and the `kubelet` watches these files.
- **Some examples of static pods are:** ApiServer, Kube-scheduler, controller-manager, ETCD etc
  
### Managing Static Pods:
1. **SSH into the Node**: Log in to the node where the static pod is defined (the control plane node for the control plane components).
2. **Find the manifest directory**: The default location is `/etc/kubernetes/manifests/`. It is set by the `staticPodPath` field in the kubelet config file `/var/lib/kubelet/config.yaml`.
3. **Create or modify the YAML file**: When you place a pod YAML in this directory, the kubelet on that node starts the pod by itself. When you edit the file, the kubelet recreates the pod.
4. **Stop the pod**: Move the file out of the directory. For example, when you move `kube-scheduler.yaml` out of the directory, the scheduler pod stops, and new pods stay in `Pending` until you move the file back.

- The kubelet creates a read-only "mirror pod" on the API server for every static pod, so you can see it with `kubectl get pods`. Its name ends with the node name, for example `kube-apiserver-controlplane`. Deleting the mirror pod with `kubectl delete` does not stop the static pod.
- Do not keep backup copies of a manifest inside `/etc/kubernetes/manifests/`. The kubelet reads every file in this directory and will try to run the backup as well.

## 🧭 Manual Pod Scheduling

Manual scheduling in Kubernetes involves assigning a pod to a specific node rather than letting the scheduler decide.

### Key Points:
- **`nodeName` Field**: Use this field in the pod specification to specify the node where the pod should run. You can only set it when you create the pod. It cannot be changed on a running pod.
- **No Scheduler Involvement**: When `nodeName` is specified, the scheduler bypasses the pod, and it’s directly assigned to the given node.

### Example Configuration:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-scheduled-pod
spec:
  nodeName: worker-node-1
  containers:
  - name: nginx
    image: nginx
```

>Note: Kubernetes will place the pod on worker-node-1 with the above configuration.



