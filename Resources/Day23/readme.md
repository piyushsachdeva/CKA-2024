# Day 23/40 - Kubernetes RBAC Explained - Role Based Access Control Kubernetes

## Check out the video below for Day23 👇

[![Day Day 23/40 - Kubernetes RBAC Explained - Role Based Access Control Kubernetes ](https://img.youtube.com/vi/uGcDt7iNFkE/sddefault.jpg)](https://youtu.be/uGcDt7iNFkE)


### Commands used in the demo

**Generate the csr key and file**

```bash
openssl genrsa -out krishna.key 2048
openssl req -new -key adam.key -out krishna.csr -subj "/CN=krishna"
```

#### to check who you are
`kubectl auth whoami`

#### to check if you have access to a particular resource
```
k auth can-i create po
k auth can-i create po --as krishna
```
#### To get the crt file in decoded format
```
kubectl get csr krishna -o jsonpath='{.status.certificate}'| base64 -d > krishna.crt
```

### Sample YAML for role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

### Sample YAML for role binding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
# You can specify more than one "subject"
- kind: User
  name: krishna # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```
