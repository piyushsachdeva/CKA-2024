# Day 54 - Kubernetes Pod Security Assignment - CKA Exam Preparation

## 📋 Prerequisites

- Kubernetes cluster (minikube, kind, or cloud-based)
- kubectl configured and working
- Basic understanding of Kubernetes pods and namespaces

## 🔐 Part 1: Understanding Linux Capabilities

Linux capabilities divide root privileges into distinct units, allowing fine-grained control over what processes can do.

### Important Linux Capabilities

#### 1. CAP_NET_ADMIN
- **Purpose**: Network administration tasks
- **Allows**: Configure network interfaces, routing tables, firewall rules
- **Risk**: Can intercept or modify network traffic
- **Example Use**: Network monitoring tools, VPN software

#### 2. CAP_SYS_ADMIN
- **Purpose**: System administration operations
- **Allows**: Mount filesystems, system configuration changes
- **Risk**: Nearly equivalent to root access
- **Example Use**: System management tools, backup software

#### 3. CAP_SYS_TIME
- **Purpose**: Set system clock
- **Allows**: Modify system time and hardware clock
- **Risk**: Can disrupt time-sensitive operations
- **Example Use**: NTP clients, time synchronization services

#### 4. CAP_CHOWN
- **Purpose**: Change file ownership
- **Allows**: Change owner and group of files
- **Risk**: Can gain access to other users' files
- **Example Use**: File management utilities


### Capability Management in Kubernetes

In a pod spec, capability names are written without the `CAP_` prefix. Capabilities are set per container, not at the pod level.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cap-demo
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    securityContext:
      capabilities:
        drop: ["ALL"]                      # Drop all capabilities first
        add: ["NET_ADMIN", "SYS_TIME"]    # Then add back only what is needed
```

```bash
# Test NET_ADMIN capability (should work)
kubectl exec cap-demo -- ip link add dummy0 type dummy
kubectl exec cap-demo -- ip link show dummy0

# Test SYS_TIME capability (should work)
kubectl exec cap-demo -- date -s "$(date '+%Y-%m-%d %H:%M:%S')"

# Test a capability that was not added - CAP_SYS_ADMIN (should fail with "Operation not permitted")
kubectl exec cap-demo -- mount -t tmpfs tmpfs /mnt
```

## 🛡️ Part 2: Security Context - Essential Fields

Security Context defines privilege and access control settings for pods and containers.

### Critical Security Context Fields for CKA

#### 1. runAsUser
- **Purpose**: Specifies the user ID to run container processes
- **Default**: The user set in the image, which is root (UID 0) for many images
- **Security**: Running as non-root reduces attack surface

```yaml
securityContext:
  runAsUser: 1000  # Run as user ID 1000 (non-root)
```

#### 2. runAsNonRoot
- **Purpose**: Ensures container cannot run as root user
- **Behavior**: The kubelet refuses to start the container if it would run as root (UID 0). The pod then shows `CreateContainerConfigError`
- **Security**: Prevents root-level access entirely

```yaml
securityContext:
  runAsNonRoot: true  # Block any attempt to run as root
```

#### 3. fsGroup
- **Purpose**: Sets group ID for volume ownership
- **Behavior**: Volumes that support ownership management are owned by this group, and new files created in them get this group. Set at the pod level only
- **Use Case**: Shared storage between containers

```yaml
securityContext:
  fsGroup: 2000  # Volumes owned by group 2000
```

#### 4. allowPrivilegeEscalation
- **Purpose**: Controls if process can gain more privileges
- **Default**: true (allows escalation). It is always true when the container is privileged or has `CAP_SYS_ADMIN`
- **Security**: Set to false to prevent privilege escalation

```yaml
securityContext:
  allowPrivilegeEscalation: false  # Prevent privilege escalation
```

### Complete Security Context Example

```yaml
# Secure container configuration
apiVersion: v1
kind: Pod
metadata:
  name: secure-demo
spec:
  securityContext:          # Pod-level security context
    runAsUser: 1000  # user id of the processes
    runAsGroup: 3000  # group id of the processes
    runAsNonRoot: true
    fsGroup: 2000  # group that owns the volumes
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox:1.28
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      runAsUser: 1000
      runAsNonRoot: true
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
```
Fields set at the container level override the same fields set at the pod level.

Open a shell in the pod and run the below commands:

```bash
kubectl exec -it secure-demo -- sh
```

```bash
id                     # uid=1000 gid=3000 groups=2000,3000
ps                     # the processes run as user 1000
ls -ld /data/demo      # the volume is owned by group 2000
touch /data/demo/test
ls -l /data/demo       # the new file belongs to user 1000 and group 2000
su -                   # fails, the container cannot become root
```


## 🧪 Part 3: Hands-on Capability and Security Context Testing

### Task 1: Test Different Capability Configurations

#### 1.1 Container with NET_ADMIN Capability

```yaml
# net-admin-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: net-admin-test
spec:
  containers:
  - name: network-tool
    image: busybox
    command: ["sleep", "3600"]
    securityContext:
      capabilities:
        add: ["NET_ADMIN"]
```

**Test Commands:**
```bash
kubectl apply -f net-admin-pod.yaml
kubectl exec -it net-admin-test -- ip link add dummy0 type dummy
# This should work - NET_ADMIN allows network interface creation
kubectl exec -it net-admin-test -- ip link show dummy0
```

Now delete the pod, replace `add: ["NET_ADMIN"]` with `drop: ["NET_ADMIN"]` in the YAML, create the pod again and run the same command. This time it fails with `Operation not permitted`.



### Task 2: Test Security Context Configurations

#### 2.1 Root User Test

```yaml
# root-user-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: root-user-test
spec:
  containers:
  - name: root-container
    image: busybox
    command: ["sleep", "3600"]
    securityContext:
      runAsUser: 0  # Root user
```

**Verification:**
```bash
kubectl exec -it root-user-test -- id
# Should show uid=0(root)
```



## 🔐 Part 4: Pod Security Standards

Now that we understand capabilities and security context, let's apply this knowledge to Pod Security Standards.

### The Three Standards

Pod Security Standards are three ready-made security levels. They are enforced by the built-in **Pod Security Admission** controller, which you switch on per namespace with labels. (PodSecurityPolicy, the older mechanism, was removed in Kubernetes 1.25.)

#### 1. Privileged
- **Security Level**: Lowest
- **Capabilities**: All allowed
- **Security Context**: No restrictions

#### 2. Baseline
- **Security Level**: Medium
- **Capabilities**: Only the default set of capabilities can be added
- **Security Context**: Blocks the known ways to escalate privileges: privileged containers, host network, host PID and host IPC, and hostPath volumes

#### 3. Restricted
- **Security Level**: Highest
- **Capabilities**: All must be dropped. Only `NET_BIND_SERVICE` may be added back
- **Security Context**: Everything in Baseline, plus the requirements listed below

### The Three Modes

Each level can be applied to a namespace in three modes, and you can combine them:

| Mode | Label | What happens to a pod that violates the level |
|---|---|---|
| enforce | `pod-security.kubernetes.io/enforce` | The pod is rejected |
| audit | `pod-security.kubernetes.io/audit` | The pod is allowed, and the violation is recorded in the audit log |
| warn | `pod-security.kubernetes.io/warn` | The pod is allowed, and the user sees a warning |

### Restricted Standard Requirements

The restricted standard requires:
- `runAsNonRoot: true`
- `allowPrivilegeEscalation: false`
- `capabilities.drop: ["ALL"]`
- No privileged containers
- No host networking, host PID or host IPC
- Seccomp profile must be set to `RuntimeDefault` or `Localhost`
- Only these volume types: configMap, secret, emptyDir, persistentVolumeClaim, projected, downwardAPI, csi and ephemeral (so no hostPath)

## 🛠️ Part 5: Implement Restricted Namespace

### Task: Create and Configure restricted-ns

```bash
# Create namespace with restricted pod security standard
kubectl create namespace restricted-ns

# Apply pod security standard labels
kubectl label namespace restricted-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

### Compliant Pod for Restricted Namespace

```yaml
# restricted-compliant-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: compliant-pod
  namespace: restricted-ns
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginxinc/nginx-unprivileged:stable-alpine
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop: ["ALL"]
```

> Note: The video uses the `nginx:alpine` image here. The pod is admitted, but the standard nginx image needs root to start, so with `runAsUser: 1000` the container crashes. The `nginxinc/nginx-unprivileged` image is built to run as a non-root user and listens on port 8080.

## 🧪 Part 6: Test All Violations in One Pod

### Combined Violation Test (Should Fail)

This single pod violates multiple restricted policy requirements:

```yaml
# all-violations-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-violations
  namespace: restricted-ns
spec:
  hostNetwork: true                    # Violation 1: Host networking
  hostPID: true                        # Violation 2: Host PID namespace
  containers:
  - name: insecure-app
    image: nginx
    securityContext:
      privileged: true                 # Violation 3: Privileged container
      runAsUser: 0                     # Violation 4: Running as root
      allowPrivilegeEscalation: true   # Violation 5: Privilege escalation allowed
      capabilities:
        add: ["SYS_ADMIN", "NET_ADMIN"] # Violation 6: Adding dangerous capabilities
    volumeMounts:
    - name: host-root
      mountPath: /host
  volumes:
  - name: host-root
    hostPath:
      path: /                          # Violation 7: Host path volume
      type: Directory
```

**What this pod violates:**
1. **Host Networking** (`hostNetwork: true`) - Direct access to host network
2. **Host PID** (`hostPID: true`) - Can see host processes
3. **Privileged Container** (`privileged: true`) - Full host access
4. **Root User** (`runAsUser: 0`) - Running as root
5. **Privilege Escalation** (`allowPrivilegeEscalation: true`) - Can gain more privileges
6. **Dangerous Capabilities** - SYS_ADMIN and NET_ADMIN capabilities
7. **Host Path Volume** - Direct access to host filesystem

## ✅ Verification and Testing

```bash
# Apply compliant pod
kubectl apply -f restricted-compliant-pod.yaml

# Try to apply the violation pod (should fail)
kubectl apply -f all-violations-pod.yaml

# Verify compliant pod is running
kubectl get pods -n restricted-ns

# Check which pod security labels a namespace has
kubectl get ns restricted-ns --show-labels
```

The API server rejects the violation pod and lists every rule that it breaks, in an error that starts with `violates PodSecurity "restricted:latest"`.

> Note: Pod Security Admission checks pods, not Deployments. A Deployment whose pod template violates the level is created without an error (you only get a warning), but its ReplicaSet cannot create any pods. If a Deployment in a namespace shows 0 ready pods, check `kubectl describe rs <replicaset-name>` and the labels of the namespace.

To check whether the existing pods of a namespace would pass a level before you enforce it, use a server-side dry run:

```bash
kubectl label --dry-run=server --overwrite ns default pod-security.kubernetes.io/enforce=restricted
```

## 🎓 Points to Remember

Security is covered in much more depth in the CKS exam. For the CKA, the usual place where this shows up is troubleshooting: a pod or a deployment that does not start because of its security context or because of the pod security level of its namespace.

1. **Security Context Fields**: runAsUser, runAsNonRoot, allowPrivilegeEscalation, fsGroup
2. **Linux Capabilities**: NET_ADMIN, SYS_ADMIN, SYS_TIME - know when to drop ALL
3. **Pod Security Standards**: Understand restricted requirements
4. **Namespace Labels**: `pod-security.kubernetes.io/enforce=restricted`

---
