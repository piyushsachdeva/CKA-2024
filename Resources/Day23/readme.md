# Day 23/40 - Kubernetes RBAC Explained - Role Based Access Control Kubernetes

## Check out the video below for Day23 👇

[![Day 23/40 - Kubernetes RBAC Explained - Role Based Access Control Kubernetes](https://img.youtube.com/vi/uGcDt7iNFkE/sddefault.jpg)](https://youtu.be/uGcDt7iNFkE)


### Commands used in the demo

**Generate the key and the csr file**

```bash
openssl genrsa -out krishna.key 2048
openssl req -new -key krishna.key -out krishna.csr -subj "/CN=krishna"
```

The `CN` in the subject becomes the user name in Kubernetes. If you add an `O` field (for example `/CN=krishna/O=dev`), it becomes the group of the user.

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
# This role binding allows "krishna" to read pods in the "default" namespace.
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

### Imperative commands for the same objects

```bash
kubectl create role pod-reader --verb=get,watch,list --resource=pods -n default
kubectl create rolebinding read-pods --role=pod-reader --user=krishna -n default

kubectl describe role pod-reader
kubectl describe rolebinding read-pods

# verify
kubectl auth can-i list pods --as krishna
kubectl auth can-i delete pods --as krishna
kubectl auth can-i --list --as krishna
```
