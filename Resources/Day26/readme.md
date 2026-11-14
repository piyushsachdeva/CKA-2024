# Day 26/40 - Kubernetes Network Policies Explained

## Check out the video below for Day26 👇

[![Day 26/40 - Kubernetes Network Policies Explained ](https://img.youtube.com/vi/eVtnevr3Rao/sddefault.jpg)](https://youtu.be/eVtnevr3Rao)

### What is a network policy

A network policy allows you to control the inbound (ingress) and outbound (egress) traffic to and from the pods.
By default, every pod in a cluster can talk to every other pod. With a network policy, you can for example block all incoming traffic to the pods in a namespace, or allow only certain pods to reach your database pods on a specific port.

- A network policy is a namespaced object. It applies to the pods that its `podSelector` selects, in its own namespace.
- Once a pod is selected by any policy, everything that the policies do not allow is blocked for that pod, in the direction listed under `policyTypes`.
- Policies only add up. There is no "deny" rule, and the result is the union of everything that all the matching policies allow.
- Network policies are enforced by the CNI plugin. Calico and Cilium support them. The default CNI of kind (kindnet) and Flannel do not enforce them, so the policy object gets created but has no effect. That is why we disable the default CNI and install Calico below.

 ![image](https://github.com/user-attachments/assets/c7d2c77f-e12d-488b-8158-f7d2b3d4d10a)


### Manifests used in the video

#### Kind cluster yaml

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30001
    hostPort: 30001
- role: worker
- role: worker
networking:
  disableDefaultCNI: true
  podSubnet: 192.168.0.0/16
```

#### Document to install `calico` on your cluster

https://docs.tigera.io/calico/latest/getting-started/kubernetes/kind

#### Application manifest

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    role: frontend
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - name: http
      containerPort: 80
      protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    role: frontend
spec:
  selector:
    role: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: backend
  labels:
    role: backend
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - name: http
      containerPort: 80
      protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    role: backend
spec:
  selector:
    role: backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: db
  labels:
    name: mysql
spec:
  selector:
    name: mysql
  ports:
  - protocol: TCP
    port: 3306
    targetPort: 3306
---
apiVersion: v1
kind: Pod
metadata:
  name: mysql
  labels:
    name: mysql
spec:
  containers:
    - name: mysql
      image: mysql:8.4
      env:
        - name: "MYSQL_USER"
          value: "mysql"
        - name: "MYSQL_PASSWORD"
          value: "mysql"
        - name: "MYSQL_DATABASE"
          value: "testdb"
        - name: "MYSQL_ROOT_PASSWORD"
          value: "verysecure"
      ports:
        - name: mysql
          containerPort: 3306
          protocol: TCP
```

#### Network policy sample used in the video

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-test
spec:
  podSelector:
    matchLabels:
      name: mysql
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
    ports:
    - port: 3306
```

This policy selects the `mysql` pod and allows incoming traffic on port 3306 only from pods with the label `role: backend`. The frontend pod can no longer reach the database.

#### Test the policy

```bash
kubectl get netpol
kubectl describe netpol db-test
kubectl exec -it backend -- curl -m 3 telnet://db:3306      # connects
kubectl exec -it frontend -- curl -m 3 telnet://db:3306     # times out
```

#### More samples

Default deny for all incoming traffic in a namespace (the empty `podSelector` selects every pod):

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

Allow traffic from pods in another namespace. Every namespace has the label `kubernetes.io/metadata.name` set to its name, so you can select a namespace without adding labels yourself:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-dev
  namespace: test
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: dev
      podSelector:
        matchLabels:
          app: nginx
    ports:
    - port: 6379
```

> Note: In the sample above, `namespaceSelector` and `podSelector` are in the same list item, so both must match (pods with `app: nginx` in the `dev` namespace). If you write them as two separate items, with a `-` before each, the rule means "any pod in dev" OR "pods with app: nginx in this namespace". This is a common mistake.

Egress policy that lets the backend pod reach only the database and DNS. When you restrict egress, remember to allow DNS (port 53), otherwise the pod cannot resolve service names:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          name: mysql
    ports:
    - port: 3306
  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
```
