# Day 10/40 - Kubernetes Namespace Explained - CKA Full Course 2024


## Check out the video below for Day10 👇

[![Day10/40 - Kubernetes Namespace Explained - CKA Full Course 2024](https://img.youtube.com/vi/yVLXIydlU_0/sddefault.jpg)](https://youtu.be/yVLXIydlU_0)

### What is a Namespace in Kubernetes

- A namespace is a logical group of resources inside a cluster. Resource names must be unique within a namespace, but the same name can be reused in another namespace
- Helps to avoid accidental deletion/modification, because you work on one namespace at a time
- You can separate resources by team, environment, application and so on, and apply RBAC, resource quotas and network policies per namespace
- A namespace does not isolate the network on its own. By default, a pod can reach pods and services in every other namespace. You need network policies (Day 26) to restrict that
- Resources in the same namespace can reach a service by its short name, for example `svc-ns1`. To reach a service in another namespace, use `<service>.<namespace>` or the full DNS name `<service>.<namespace>.svc.cluster.local`
- Not every resource lives in a namespace. Nodes, PersistentVolumes, StorageClasses, ClusterRoles and Namespaces themselves are cluster-scoped. Run `kubectl api-resources --namespaced=false` to see the full list


![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/d9ae95d5-7224-4d5b-b260-ed09fc53c6fd)

### Commands used in the video

```bash
kubectl get namespaces
kubectl create namespace demo
kubectl get pods -n demo
kubectl get pods --all-namespaces        # or -A

# set the default namespace for your current context
kubectl config set-context --current --namespace=demo

# deleting a namespace deletes everything inside it
kubectl delete namespace demo
```
