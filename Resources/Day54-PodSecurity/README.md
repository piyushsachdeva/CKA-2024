# Kubernetes Pod Security Assignment - CKA Exam Preparation

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

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-demo
spec:
  containers:
  - name: app
    image: nginx:alpine
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"]    # Add specific capabilities
        drop: ["ALL"]                      # Drop all capabilities first 
```

```
# Test NET_ADMIN capability (should work)
kubectl exec secure-demo -- ip link add dummy0 type dummy

# Test SYS_TIME capability (should work)
kubectl exec secure-demo -- date -s "$(date)"

# Test restricted capability - CAP_SYS_ADMIN (should fail)
kubectl exec secure-demo -- mount -t tmpfs tmpfs /tmp/test
```

## 🛡️ Part 2: Security Context - Essential Fields

Security Context defines privilege and access control settings for pods and containers.

### Critical Security Context Fields for CKA

#### 1. runAsUser
- **Purpose**: Specifies the user ID to run container processes
- **Default**: Usually root (UID 0)
- **Security**: Running as non-root reduces attack surface

```yaml
securityContext:
  runAsUser: 1000  # Run as user ID 1000 (non-root)
```

#### 2. runAsNonRoot
- **Purpose**: Ensures container cannot run as root user
- **Behavior**: Kubernetes blocks pod if image tries to run as root
- **Security**: Prevents root-level access entirely

```yaml
securityContext:
  runAsNonRoot: true  # Block any attempt to run as root
```

#### 3. fsGroup
- **Purpose**: Sets group ID for volume ownership
- **Behavior**: All volumes owned by this group
- **Use Case**: Shared storage between containers

```yaml
securityContext:
  fsGroup: 2000  # Volumes owned by group 2000
```

#### 4. allowPrivilegeEscalation
- **Purpose**: Controls if process can gain more privileges
- **Default**: true (allows escalation)
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
    runAsUser: 1000  # process id
    runAsGroup: 3000  # group id of process
    runAsNonRoot: true
    fsGroup: 2000  # file ownership group
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
 Run below commands
```
 ps
 cd /data;ls -l
 touch test; ls -l
 id
su -
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
ip link show
# Now add the drop and test again
drop: ["NET_ADMIN"]
```



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

#### 1. Privileged
- **Security Level**: Lowest
- **Capabilities**: All allowed
- **Security Context**: No restrictions

#### 2. Baseline
- **Security Level**: Medium
- **Capabilities**: Some restrictions
- **Security Context**: Basic protections

#### 3. Restricted
- **Security Level**: Highest
- **Capabilities**: Only safe ones allowed
- **Security Context**: Strict requirements

### Restricted Standard Requirements

The restricted standard requires:
- `runAsNonRoot: true`
- `allowPrivilegeEscalation: false`
- `capabilities.drop: ["ALL"]`
- No privileged containers
- No host networking
- Seccomp profile must be set

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
    image: nginx:alpine
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop: ["ALL"]
```

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
  containers:
  - name: insecure-app
    image: nginx
    securityContext:
      privileged: true                 # Violation 1: Privileged container
      runAsUser: 0                     # Violation 2: Running as root
      allowPrivilegeEscalation: true   # Violation 3: Privilege escalation allowed
      capabilities:
        add: ["SYS_ADMIN", "NET_ADMIN"] # Violation 4: Adding dangerous capabilities
    volumeMounts:
    - name: host-root
      mountPath: /host
  volumes:
  - name: host-root
    hostPath:
      path: /                          # Violation 5: Host path volume
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

# Try to apply violation pods (should fail)
kubectl apply -f violation-privileged.yaml
kubectl apply -f violation-root.yaml
kubectl apply -f violation-hostnetwork.yaml

# Check events for violation messages
kubectl get events -n restricted-ns

# Verify compliant pod is running
kubectl get pods -n restricted-ns
```

## 🎓 CKA Exam Focus Points

### High Priority Topics
1. **Security Context Fields**: runAsUser, runAsNonRoot, allowPrivilegeEscalation, fsGroup
2. **Linux Capabilities**: NET_ADMIN, SYS_ADMIN, SYS_TIME - know when to drop ALL
3. **Pod Security Standards**: Understand restricted requirements
4. **Namespace Labels**: `pod-security.kubernetes.io/enforce=restricted`

---
