# Kubernetes Admission Control Assignment


In this assignment, you'll learn about one of Kubernetes' most powerful security and governance features: 
**Admission Control**. Think of it as the bouncer at a club - it decides what gets into your cluster and 
what doesn't!

---

## 📚 Part 1: Understanding Admission Control

### What is Admission Control?

Imagine you're running a restaurant (your Kubernetes cluster). Before customers (resources) can sit down and eat, they need to pass through several checkpoints:

1. **Authentication**: "Are you who you say you are?" (Like checking ID)
2. **Authorization**: "Are you allowed to be here?" (Like checking reservations)
3. **Admission Control**: "Do you meet our dress code and other requirements?" (The final check)

Admission control is the **final gatekeeper** that validates and potentially modifies requests before they're stored in etcd.

### The Admission Control Flow

```
API Request → Authentication → Authorization → Admission Control → etcd
```

### Key Concepts Made Simple

**Admission Controllers**: Built-in plugins that run during the admission phase
**Mutating Webhooks**: Can **change** your request (like adding labels)
**Validating Webhooks**: Can **accept or reject** your request (like enforcing rules)

---

## 🔧 Part 2: Hands-On Lab Setup

### Prerequisites
- A Kubernetes cluster (minikube, kind, or cloud cluster)
- kubectl configured
- Basic understanding of pods, deployments, and services
- SSH/root access to control plane node (for apiserver configuration)

### Step 1: Check Default Admission Controllers

Let's first understand what admission controllers are enabled by default in your cluster:

```bash
# Method 1: Check API server pod configuration
kubectl get pod kube-apiserver-controlplane -n kube-system -o yaml | grep -i admission

# Method 2: Check API server process (on control plane node)
ps aux | grep kube-apiserver | grep enable-admission-plugins

# Method 3: For managed clusters, check cluster info
kubectl exec -it kube-apiserver-controlplane -n kube-system -- kube-apiserver -h | grep 'enable-admission-plugins'

```

**Expected Output**: You should see controllers like:
- `NamespaceLifecycle`
- `LimitRanger` 
- `ServiceAccount`
- `DefaultStorageClass`
- `ResourceQuota`
- `DefaultTolerationSeconds`
- `NodeRestriction`

---

## 🧪 Part 3: NamespaceAutoProvision Demonstration

### Exercise 1: Understanding NamespaceLifecycle Controller

The `NamespaceLifecycle` admission controller (enabled by default) prevents creation of resources in non-existent namespaces. Let's see this in action!

**Step 1**: Try to create a pod in a non-existent namespace

```yaml
# Create file: pod-in-missing-namespace.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: test  # This namespace doesn't exist!
spec:
  containers:
  - name: nginx
    image: nginx:1.20
```

**Step 2**: Apply and observe the error

```bash
kubectl apply -f pod-in-missing-namespace.yaml
```

**Expected Error**: 
```
Error from server (NotFound): namespaces "test" not found
```

### Exercise 2: Enabling NamespaceAutoProvision

Now let's enable the `NamespaceAutoProvision` admission controller to automatically create missing namespaces.

**Step 1**: Backup the current API server configuration

```bash
# SSH to your control plane node first
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml.backup
```

**Step 2**: Edit the API server configuration

```bash
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

Find the `--enable-admission-plugins` line and add `NamespaceAutoProvision`:

```yaml
# Before (example):
- --enable-admission-plugins=NodeRestriction,ResourceQuota,LimitRanger

# After:
- --enable-admission-plugins=NodeRestriction,ResourceQuota,LimitRanger,NamespaceAutoProvision
```

**Step 3**: Wait for API server to restart (it will restart automatically)

```bash
# Watch the API server pod restart
kubectl -n kube-system get pods -w | grep kube-apiserver
```

**Step 4**: Verify the admission controller is enabled

```bash
kubectl -n kube-system get pod kube-apiserver-controlplane -o yaml | grep -i admission
```

**Step 5**: Now try creating the pod again

```bash
kubectl apply -f pod-in-missing-namespace.yaml
```

**Expected Result**: The pod should be created successfully, and the `test` namespace should be auto-created!

**Step 6**: Verify namespace was created

```bash
kubectl get namespaces
kubectl get pods -n test
```
---

## 🛠️ Part 4: Working with Built-in Admission Controllers

### Exercise 1: ResourceQuota (Validating Controller)

ResourceQuota prevents resource overconsumption - like having a spending limit on your credit card.

**Step 1**: Create a namespace with a resource quota

```yaml
# Create file: resource-quota-demo.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: quota-demo
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: quota-demo
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "4"
```

**Step 2**: Apply the configuration

```bash
kubectl apply -f resource-quota-demo.yaml
```

**Step 3**: Try to create a pod that exceeds the quota

```yaml
# Create file: big-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: big-pod
  namespace: quota-demo
spec:
  containers:
  - name: big-container
    image: nginx
    resources:
      requests:
        memory: "2Gi"  # This exceeds our quota!
        cpu: "1"
```

**Step 4**: Apply and observe the error

```bash
kubectl apply -f big-pod.yaml
```

**Question for Students**: What error did you get? Why did the admission controller reject this pod?

### Exercise 3: LimitRanger (Mutating Controller)

LimitRanger automatically adds resource limits - like a helpful assistant that fills out forms for you.

**Step 1**: Create a LimitRange

```yaml
# Create file: limit-range-demo.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
  namespace: quota-demo
spec:
  limits:
  - default:
      memory: "512Mi"
      cpu: "200m"
    defaultRequest:
      memory: "256Mi"
      cpu: "100m"
    type: Container
```

**Step 2**: Apply the LimitRange

```bash
kubectl apply -f limit-range-demo.yaml
```

**Step 3**: Create a pod without specifying resources

```yaml
# Create file: simple-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  namespace: quota-demo
spec:
  containers:
  - name: simple-container
    image: nginx
```

**Step 4**: Apply and check the pod

```bash
kubectl apply -f simple-pod.yaml
kubectl get pod simple-pod -n quota-demo -o yaml | grep -A 10 resources
```

**Question for Students**: What resources were automatically added to your pod?
