# Day 46 - Pod Priority and Preemption: Solution to the Assignment

The assignment is in [task.md](task.md).

## Introduction

This solution demonstrates how to implement Pod Priority and Preemption in Kubernetes. 

When cluster resources are limited, not all pods can run simultaneously. Kubernetes uses Pod Priority to determine which pods should be scheduled 
first and potentially preempt (evict) lower priority pods when necessary.

## Step 1: Create Priority Classes

First, create three priority classes with different priority values:

### High Priority Class

```yaml
# high-priority.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "This priority class should be used for high priority service pods only."
```

### Medium Priority Class

```yaml
# medium-priority.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: medium-priority
value: 100000
globalDefault: false
description: "This priority class should be used for medium priority service pods."
```

### Low Priority Class

```yaml
# low-priority.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 10000
globalDefault: true
description: "This priority class should be used for low priority service pods."
```

Apply these manifests:

```bash
kubectl apply -f high-priority.yaml
kubectl apply -f medium-priority.yaml
kubectl apply -f low-priority.yaml
```

Verify the priority classes:

```bash
kubectl get priorityclasses
```

You will also see two built-in classes, `system-cluster-critical` and `system-node-critical`. Kubernetes uses them for its own components such as CoreDNS and kube-proxy. Their values are above 2 billion, while the classes that you create can have a value of up to 1 billion.

> Note: `low-priority` has `globalDefault: true`, so every new pod in the cluster that does not set a `priorityClassName` gets this class. Only one PriorityClass can be the global default. Without a global default, such pods have priority 0. The cleanup step at the end removes it again.

You can also create a PriorityClass with a single command:

```bash
kubectl create priorityclass high-priority --value=1000000 --description="high priority" --dry-run=client -o yaml
```

## Step 2: Create Pods with Different Priorities

Now, create pods that use these priority classes:

### High Priority Pod

```yaml
# high-priority-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-priority-nginx
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "128Mi"
        cpu: "500m"
  priorityClassName: high-priority
```

### Medium Priority Pod

```yaml
# medium-priority-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: medium-priority-nginx
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "128Mi"
        cpu: "500m"
  priorityClassName: medium-priority
```

### Low Priority Pod

```yaml
# low-priority-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: low-priority-nginx
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "128Mi"
        cpu: "500m"
  priorityClassName: low-priority
```

Apply these manifests:

```bash
kubectl apply -f low-priority-pod.yaml
kubectl apply -f medium-priority-pod.yaml
kubectl apply -f high-priority-pod.yaml
```

## Step 3: Create a Resource-Constrained Environment

To demonstrate preemption, the nodes must be full. First check how much CPU your worker nodes can allocate and how much of it is already requested:

```bash
kubectl describe nodes | grep -A 7 "Allocated resources"
```

Then create several resource-intensive pods with low priority. Set `replicas` high enough that the CPU requests fill all your worker nodes. The demo is ready when at least one `resource-hog` pod is stuck in `Pending`.

```yaml
# resource-hog.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-hog
  labels:
    app: resource-hog
spec:
  replicas: 5
  selector:
    matchLabels:
      app: resource-hog
  template:
    metadata:
      labels:
        app: resource-hog
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            memory: "256Mi"
            cpu: "500m"
      priorityClassName: low-priority
```

Apply this manifest:

```bash
kubectl apply -f resource-hog.yaml
kubectl get pods -o wide

# if no resource-hog pod is Pending yet, add more replicas
kubectl scale deployment resource-hog --replicas=10
```

## Step 4: Deploy a Critical High-Priority Pod

Now, create a high-priority pod. There is no free CPU left for it, so the scheduler has to remove lower-priority pods to make room:

```yaml
# critical-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-nginx
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "512Mi"
        cpu: "1000m"
  priorityClassName: high-priority
```

Apply this manifest:

```bash
kubectl apply -f critical-pod.yaml
```

## Step 5: Observe Preemption

Watch the pods and observe preemption:

```bash
kubectl get pods -o wide -w
```

You should see one or more low-priority pods being terminated to make room for the high-priority pod. The Deployment recreates the pods that were removed, and they stay in `Pending` because there is no room for them.

> Note: The request of the critical pod must be smaller than the allocatable CPU of a single node. The scheduler preempts pods only when removing them makes the new pod fit. If the pod asks for more than a whole node has (for example 15 CPUs on a 2 CPU node), nothing is preempted and the pod just stays in `Pending`.

Check the events to observe preemption:

```bash
kubectl get events --sort-by=.metadata.creationTimestamp | grep -i preempt
kubectl get pods -o custom-columns=NAME:.metadata.name,PRIORITY:.spec.priority,CLASS:.spec.priorityClassName,STATUS:.status.phase
```

## Preemption policy

By default a PriorityClass has `preemptionPolicy: PreemptLowerPriority`. If you set `preemptionPolicy: Never`, pods of that class are still placed ahead of lower-priority pods in the scheduling queue, but they never evict running pods.



## Cleanup

To clean up the resources created in this demo:

```bash
kubectl delete -f high-priority-pod.yaml
kubectl delete -f medium-priority-pod.yaml
kubectl delete -f low-priority-pod.yaml
kubectl delete -f resource-hog.yaml
kubectl delete -f critical-pod.yaml
kubectl delete -f high-priority.yaml
kubectl delete -f medium-priority.yaml
kubectl delete -f low-priority.yaml
```
