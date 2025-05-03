kubectl get nodes 

kubectl config get-clusters
```
 ✘ idubi@DESKTOP-82998RE  3.12  ~/.../40DAysOfK8-CKA/Resources   Day06 ●  kubectl config get-clusters
NAME
kind-cka-cluster-1
kind-cka-cluster-2
docker-desktop
```
kubectl config get-contexts
```
 ✘ idubi@DESKTOP-82998RE  3.12  ~/.../40DAysOfK8-CKA/Resources   Day06 ●  kubectl config get-contexts
CURRENT   NAME                 CLUSTER              AUTHINFO             NAMESPACE
          docker-desktop       docker-desktop       docker-desktop       
          kind-cka-cluster-1   kind-cka-cluster-1   kind-cka-cluster-1   
*         kind-cka-cluster-2   kind-cka-cluster-2   kind-cka-cluster-2   
```
 
kubectl config use-context kind-cka-cluster-1
```
Switched to context "kind-cka-cluster-1".
```
kubectl config get-contexts

```
CURRENT   NAME                 CLUSTER              AUTHINFO             NAMESPACE
          docker-desktop       docker-desktop       docker-desktop       
*         kind-cka-cluster-1   kind-cka-cluster-1   kind-cka-cluster-1   
          kind-cka-cluster-2   kind-cka-cluster-2   kind-cka-cluster-2   
 idubi@DESKTOP-82998RE  3.12  ~/.../40DAysOfK8-CKA/Resources   Day06 ●  
```
kind delete cluster --name cka-cluster-2
```
Deleting cluster "cka-cluster-2" ...
Deleted nodes: ["cka-cluster-2-control-plane2" "cka-cluster-2-worker2" "cka-cluster-2-control-plane" "cka-cluster-2-external-load-balancer" "cka-cluster-2-worker4" "cka-cluster-2-worker" "cka-cluster-2-worker3"]
```
kind get clusters
```
cka-cluster-1
```

kubectl config get-clusters
```
NAME
docker-desktop
kind-cka-cluster-1`
```
 kind create cluster --image kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f --name cka-cluster-2  --config kind-2master-4workers.yaml
 ```
Creating cluster "cka-cluster-2" ...
 ✓ Ensuring node image (kindest/node:v1.32.2) 🖼
 ✓ Preparing nodes 📦 📦 📦 📦 📦 📦  
 ✓ Configuring the external load balancer ⚖️ 
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining more control-plane nodes 🎮 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-cka-cluster-2"
You can now use your cluster with:

kubectl cluster-info --context kind-cka-cluster-2

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```
kubectl cluster-info --context kind-cka-cluster-2
``` 
Kubernetes control plane is running at https://127.0.0.1:42379
CoreDNS is running at https://127.0.0.1:42379/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
 
 ```
 kubectl get nodes 

```
NAME                           STATUS   ROLES           AGE     VERSION
cka-cluster-2-control-plane    Ready    control-plane   4m40s   v1.32.2
cka-cluster-2-control-plane2   Ready    control-plane   4m34s   v1.32.2
cka-cluster-2-worker           Ready    <none>          4m27s   v1.32.2
cka-cluster-2-worker2          Ready    <none>          4m27s   v1.32.2
cka-cluster-2-worker3          Ready    <none>          4m27s   v1.32.2
cka-cluster-2-worker4          Ready    <none>          4m27s   v1.32.2
```
kubectl config get-contexts
```
CURRENT   NAME                 CLUSTER              AUTHINFO             NAMESPACE
          docker-desktop       docker-desktop       docker-desktop       
          kind-cka-cluster-1   kind-cka-cluster-1   kind-cka-cluster-1   
*         kind-cka-cluster-2   kind-cka-cluster-2   kind-cka-cluster-2   
```
kubectl config get-clusters
```
NAME
kind-cka-cluster-2
docker-desktop
kind-cka-cluster-1
```