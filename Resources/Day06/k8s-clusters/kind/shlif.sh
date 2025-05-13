

#1 install go 
sudo apt install golang-go

#2 install kind : 
 For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


#3. install cluster  https://github.com/kubernetes-sigs/kind/releases
#   kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f

kind create cluster --image kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f --name cka-cluster-1


kubectl cluster-info
#  ✘ idubi@DESKTOP-82998RE  3.12  ~/.../40DAysOfK8-CKA/Resources   Day06 ●  kubectl cluster-info
# Kubernetes control plane is running at https://127.0.0.1:38979
# CoreDNS is running at https://127.0.0.1:38979/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
# 
# To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

#4 configure clusters
#https://kind.sigs.k8s.io/docs/user/quick-start/#advanced

kind create cluster --image kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f / 
--name cka-cluster-2  --config kind-2master-4workers


#CURRENT   NAME                 CLUSTER              AUTHINFO             NAMESPACE
#          docker-desktop       docker-desktop       docker-desktop       
#          kind-cka-cluster-1   kind-cka-cluster-1   kind-cka-cluster-1   
#*         kind-cka-cluster-2   kind-cka-cluster-2   kind-cka-cluster-2   
# idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl config get-users
# 

CURRENT   NAME                 CLUSTER              AUTHINFO             NAMESPACE
          docker-desktop       docker-desktop       docker-desktop       
          kind-cka-cluster-1   kind-cka-cluster-1   kind-cka-cluster-1   
*         kind-cka-cluster-2   kind-cka-cluster-2   kind-cka-cluster-2   
 idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl config get-users


 ✘ idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl config
Modify kubeconfig files using subcommands like "kubectl config set current-context my-context".

 The loading order follows these rules:

  1.  If the --kubeconfig flag is set, then only that file is loaded. The flag may only be set once and no merging takes
place.
  2.  If $KUBECONFIG environment variable is set, then it is used as a list of paths (normal path delimiting rules for
your system). These paths are merged. When a value is modified, it is modified in the file that defines the stanza. When
a value is created, it is created in the first file that exists. If no files in the chain exist, then it creates the
last file in the list.
  3.  Otherwise, ${HOME}/.kube/config is used and no merging takes place.

Available Commands:
  current-context   Display the current-context
  delete-cluster    Delete the specified cluster from the kubeconfig
  delete-context    Delete the specified context from the kubeconfig
  delete-user       Delete the specified user from the kubeconfig
  get-clusters      Display clusters defined in the kubeconfig
  get-contexts      Describe one or many contexts
  get-users         Display users defined in the kubeconfig
  rename-context    Rename a context from the kubeconfig file
  set               Set an individual value in a kubeconfig file
  set-cluster       Set a cluster entry in kubeconfig
  set-context       Set a context entry in kubeconfig
  set-credentials   Set a user entry in kubeconfig
  unset             Unset an individual value in a kubeconfig file
  use-context       Set the current-context in a kubeconfig file
  view              Display merged kubeconfig settings or a specified kubeconfig file

Usage:
  kubectl config SUBCOMMAND [options]



# ✘⚙ idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl config use-context kind-cka-cluster-2
#Switched to context "kind-cka-cluster-2".
# idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl get nodes 
#NAME                           STATUS   ROLES           AGE   VERSION
#cka-cluster-2-control-plane    Ready    control-plane   20m   v1.32.2
#cka-cluster-2-control-plane2   Ready    control-plane   20m   v1.32.2
#cka-cluster-2-worker           Ready    <none>          20m   v1.32.2
#cka-cluster-2-worker2          Ready    <none>          20m   v1.32.2
#cka-cluster-2-worker3          Ready    <none>          20m   v1.32.2
#cka-cluster-2-worker4          Ready    <none>          20m   v1.32.2
# idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl config use-context kind-cka-cluster-1
#Switched to context "kind-cka-cluster-1".
# idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl get nodes 
#NAME                          STATUS   ROLES           AGE   VERSION
#cka-cluster-1-control-plane   Ready    control-plane   37m   v1.32.2
# idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●  kubectl config get-contexts
#CURRENT   NAME                 CLUSTER              AUTHINFO             NAMESPACE
#          docker-desktop       docker-desktop       docker-desktop       
#*         kind-cka-cluster-1   kind-cka-cluster-1   kind-cka-cluster-1   
#          kind-cka-cluster-2   kind-cka-cluster-2   kind-cka-cluster-2   
# idubi@DESKTOP-82998RE  3.12  ~/.../k8s-cluster/kind   Day06 ●    