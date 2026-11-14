# Day 51 - Kubernetes Admission Control Assignment


In this assignment, you'll learn about **Admission Control**, the step where the API server checks, and sometimes changes, a request before saving it. Think of it as the bouncer at a club - it decides what gets into your cluster and 
what doesn't!

---

## 📚 Part 1: Understanding Admission Control

### What is Admission Control?

Imagine you're running a restaurant (your Kubernetes cluster). Before customers (resources) can sit down and eat, they need to pass through several checkpoints:

1. **Authentication**: "Are you who you say you are?" (Like checking ID)
2. **Authorization**: "Are you allowed to be here?" (Like checking reservations)
3. **Admission Control**: "Do you meet our dress code and other requirements?" (The final check)

Admission control is the **final gatekeeper** that validates and potentially modifies requests before they're stored in etcd. It applies only to requests that create, update or delete objects. Read requests (get, list, watch) do not go through admission control.

### The Admission Control Flow

```
API Request → Authentication → Authorization → Mutating admission → Schema validation → Validating admission → etcd
```

Mutating admission runs first, so that the validating step checks the final version of the object.

### Key Concepts Made Simple

- **Admission Controllers**: Built-in plugins that are compiled into the API server and run during the admission phase. Some of them mutate (for example `LimitRanger`, `DefaultStorageClass`, `ServiceAccount`), some validate (for example `ResourceQuota`, `PodSecurity`, `NamespaceLifecycle`)
- **Mutating Webhooks**: Your own code, called by the API server, that can **change** a request (like adding labels or a sidecar). Registered with a `MutatingWebhookConfiguration`
- **Validating Webhooks**: Your own code that can **accept or reject** a request (like enforcing rules). Registered with a `ValidatingWebhookConfiguration`
- **ValidatingAdmissionPolicy**: Validation rules written in CEL directly in a Kubernetes object, without running a webhook server. Stable since Kubernetes 1.30

---

## 🔧 Part 2: Hands-On Lab Setup

### Prerequisites
- A kubeadm cluster where you have SSH/root access to the control plane node (the cluster from Day 27 works). On a managed cloud cluster you cannot change the API server flags, so Exercise 2 of Part 3 is not possible there
- kubectl configured
- Basic understanding of pods, deployments, and services

### Step 1: Check Default Admission Controllers

Let's first understand what admission controllers are enabled by default in your cluster:

```bash
# Method 1: Check API server pod configuration
kubectl get pod kube-apiserver-controlplane -n kube-system -o yaml | grep -i admission

# Method 2: Check API server process (on control plane node)
ps aux | grep kube-apiserver | grep enable-admission-plugins

# Method 3: Check the manifest on the control plane node
sudo grep admission /etc/kubernetes/manifests/kube-apiserver.yaml

# List the plugins that are enabled by default, even when they are not in the flag
kubectl exec -it kube-apiserver-controlplane -n kube-system -- kube-apiserver -h | grep 'enable-admission-plugins'

```

Replace `kube-apiserver-controlplane` with the name of the API server pod in your cluster (`kubectl get pods -n kube-system`).

**Expected Output**: On a kubeadm cluster, the first three methods show only `--enable-admission-plugins=NodeRestriction`. That flag lists the plugins that are enabled **in addition to** the defaults. The last command prints the default list, which has controllers like:
- `NamespaceLifecycle`
- `LimitRanger` 
- `ServiceAccount`
- `DefaultStorageClass`
- `ResourceQuota`
- `DefaultTolerationSeconds`
- `MutatingAdmissionWebhook`
- `ValidatingAdmissionWebhook`
- `PodSecurity`

To switch off a default plugin, you use the flag `--disable-admission-plugins`.

---

## 🧪 Part 3: NamespaceLifecycle and NamespaceAutoProvision Demonstration

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
    image: nginx
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
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/kube-apiserver.yaml.backup
```

> Note: Keep the backup **outside** `/etc/kubernetes/manifests/`. The kubelet reads every file in that directory as a static pod manifest, so a backup copy stored there makes it try to run a second API server.

**Step 2**: Edit the API server configuration

```bash
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

Find the `--enable-admission-plugins` line and add `NamespaceAutoProvision`:

```yaml
# Before:
- --enable-admission-plugins=NodeRestriction

# After:
- --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision
```

**Step 3**: Wait for API server to restart (it will restart automatically)

```bash
# kubectl does not respond while the API server restarts, so watch the container with crictl
sudo crictl ps | grep kube-apiserver

# once it is back
kubectl -n kube-system get pods | grep kube-apiserver
```

If the API server does not come back after a couple of minutes, there is a typo in the manifest. Check `sudo crictl ps -a | grep kube-apiserver` and `sudo journalctl -u kubelet | tail -30`, or restore the backup with `sudo cp /tmp/kube-apiserver.yaml.backup /etc/kubernetes/manifests/kube-apiserver.yaml`.

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

**Step 7**: Remove `NamespaceAutoProvision` from the flag again. It is useful for this demo, but on a real cluster a typo in a namespace name would silently create a new namespace.
---

## 🛠️ Part 4: Working with Built-in Admission Controllers

### Exercise 3: ResourceQuota (Validating Controller)

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
        memory: "2Gi"  # This exceeds our quota of 1Gi for requests.memory!
        cpu: "1"
      limits:
        memory: "2Gi"
        cpu: "1"
```

> Note: When a quota covers `limits.cpu` and `limits.memory`, every pod in the namespace must set limits, which is why the pod above has them. A pod without limits is rejected with a different error, `must specify limits.cpu ... limits.memory`, unless a LimitRange supplies default values (see the next exercise).

**Step 4**: Apply and observe the error

```bash
kubectl apply -f big-pod.yaml
```

**Question for Students**: What error did you get? Why did the admission controller reject this pod?

You should see an error like `exceeded quota: compute-quota, requested: requests.memory=2Gi, used: requests.memory=0, limited: requests.memory=1Gi`.

```bash
kubectl describe resourcequota compute-quota -n quota-demo
```

### Exercise 4: LimitRanger (Mutating Controller)

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

You should see that the pod now has a memory request of 256Mi and a CPU request of 100m, with limits of 512Mi and 200m. The LimitRanger admission controller added them while the pod was being created.

```bash
kubectl describe limitrange mem-limit-range -n quota-demo
kubectl describe resourcequota compute-quota -n quota-demo
```

A LimitRange can also set `min` and `max` values per container. A pod that asks for less than `min` or more than `max` is rejected.

---

## 🔌 Part 5: Admission Webhooks and Policies

You do not have to write a webhook for the CKA exam, but you should be able to find the ones that are installed and understand what they do, because a broken webhook is a common reason for "I cannot create pods any more".

```bash
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations
kubectl describe validatingwebhookconfiguration <name>
kubectl get validatingadmissionpolicies
```

Things to look at in a webhook configuration:
- `rules`: which operations and resources are sent to the webhook
- `clientConfig.service`: the Service that the API server calls. If that Service has no ready pods, the webhook cannot answer
- `failurePolicy`: `Fail` means the request is rejected when the webhook cannot be reached. `Ignore` means the request is allowed
- `namespaceSelector`: the namespaces that the webhook applies to

An example of a ValidatingAdmissionPolicy that rejects Deployments with more than 5 replicas in namespaces that have the label `environment: test`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: replica-limit
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["deployments"]
  validations:
  - expression: "object.spec.replicas <= 5"
    message: "A deployment in a test namespace can have at most 5 replicas"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: replica-limit-binding
spec:
  policyName: replica-limit
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        environment: test
```

## 🧹 Clean Up

```bash
kubectl delete namespace quota-demo test
kubectl delete validatingadmissionpolicybinding replica-limit-binding
kubectl delete validatingadmissionpolicy replica-limit
```
