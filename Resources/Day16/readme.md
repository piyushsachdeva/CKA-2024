# Day 16/40 - Kubernetes Requests and Limits

## Check out the video below for Day16 👇

[![Day 16/40 - Kubernetes Requests and Limits](https://img.youtube.com/vi/Q-mk6EZVX_Q/sddefault.jpg)](https://youtu.be/Q-mk6EZVX_Q)


# Understanding Kubernetes Requests & Limits 🚀🔧

Welcome to the Kubernetes Requests & Limits guide! This document complements our video explaining managing resource allocation in your Kubernetes cluster. Let’s explore the essentials of Requests and Limits, why they matter, and how to use them effectively.

---

## 🏙️ What's the Deal with Requests & Limits?

Think of your Kubernetes cluster as a bustling city and pods as tenants in an apartment building. Each tenant (pod) requires specific resources like CPU and memory to function:

- **Requests**: This is the amount of CPU and memory that is reserved for a container. The scheduler uses the requests to pick a node, so a pod is only placed on a node that has that much unreserved capacity. Think of it as a guaranteed reservation.
- **Limits**: This is the maximum amount of CPU and memory a container can use. It acts as a safety cap to prevent any container from consuming more than its fair share and disrupting others.

Requests and limits are set per container, not per pod. CPU is measured in cores or millicores (`500m` is half a core) and memory in bytes (`128Mi`, `1Gi`).

What happens at the limit is different for CPU and memory:
- **CPU**: the container is throttled. It becomes slower but keeps running.
- **Memory**: the container is killed with the reason `OOMKilled` and restarted as per the pod's restart policy.

---

## 🧐 Why are Requests & Limits Important?

- **Resource Control**: By setting limits, you prevent a single pod from monopolizing the node, which can starve the other pods of CPU and memory. ☠️ Why can an OOM kill be a good thing? Because it stops only the container that crossed its limit. Otherwise, that container could consume all the memory on the node and bring down everything running there. Killing one container is a better option than losing the node.
- **Predictability**: Requests help the scheduler allocate resources efficiently and ensure pods have the necessary resources to run effectively.

---

## 🔍 Exploring Resource Management in Action

In our video, we demonstrated some practical examples using YAML files and Kubernetes commands:

1. **Using more memory than the limit**:
   - The container below has a memory limit of 100Mi but tries to allocate 250M, so it is killed with `OOMKilled` and the pod goes into `CrashLoopBackOff`.
     
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo-2
  namespace: mem-example
spec:
  containers:
  - name: memory-demo-2-ctr
    image: polinux/stress
    resources:
      requests:
        memory: "50Mi"
      limits:
        memory: "100Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "250M", "--vm-hang", "1"]
```

2. **Staying within the limit**:
   - The container below allocates 150M, which is more than its request (100Mi) but less than its limit (200Mi), so it keeps running.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo
  namespace: mem-example
spec:
  containers:
  - name: memory-demo-ctr
    image: polinux/stress
    resources:
      requests:
        memory: "100Mi"
      limits:
        memory: "200Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
```

3. **Requesting more memory than any node has**:
   - If the request is bigger than the free capacity of every node, the pod is never scheduled and stays in `Pending`. `kubectl describe pod` shows `Insufficient memory` in the events.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo-3
  namespace: mem-example
spec:
  containers:
  - name: memory-demo-3-ctr
    image: polinux/stress
    resources:
      requests:
        memory: "1000Gi"
      limits:
        memory: "1000Gi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
```

---

## Metrics server

`kubectl top` needs the metrics server, which is not installed by default on kind or kubeadm clusters.

```bash
kubectl apply -f metrics-server.yaml
kubectl top nodes
kubectl top pods -n mem-example
```

The `metrics-server.yaml` in this folder is the official v0.9.1 manifest with one extra flag, `--kubelet-insecure-tls`. Kind and kubeadm clusters use self-signed kubelet certificates, and without this flag the metrics server cannot scrape the kubelets. Do not use this flag on a production cluster.

> Note: The video uses metrics server v0.7.1. The manifest in this folder has been updated to v0.9.1.
