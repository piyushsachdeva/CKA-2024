# Day46 Pod Priority and Preemption Solution

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

To demonstrate preemption, create several resource-intensive pods with low priority:

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
```

## Step 4: Deploy a Critical High-Priority Pod

Now, create a high-priority pod that requires substantial resources:

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
        cpu: "15000m"
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

You should see one or more low-priority pods being terminated to make room for the high-priority pod.

Check the events to observe preemption:

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```



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
