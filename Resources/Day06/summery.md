
# Create Your Own K8s Multi-Node Platform – KUBEADM & DIND  
## 40 Days of K8s – CKA Challenge (06/40)

@piyushsachdeva

[Day 6/40 - Kubernetes Multi Node Cluster Setup Step By Step | Kind Tutorial](https://www.youtube.com/watch?v=RORhczcOrWs)

### In this post, I demonstrate two architectures I used to create a functioning multi-node Kubernetes environment.
<hr/>

This environment serves as a sandbox for upcoming lessons.

### The two environments are based on different architectures:
<HR/>

#### 1. Containerized architecture – using the KIND Kubernetes provider over Docker  
#### 2. VM-based architecture – using a fully functioning KUBEADM setup  

---

### 1. KIND: Containerized Architecture (KIND over Docker)

#### Prerequisites:
- Golang > 1.6  
    ```sh
    sudo apt install golang-go
    ```
- Docker (already installed)  
- `kubectl` – Kubernetes CLI  
    ```sh
    # 1. Download the latest version
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

    # 2. Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # 3. Test the installation
    kubectl version --client
    ```

#### Installation:
- KIND:
    ```sh
    # For AMD64 / x86_64
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64

    # For ARM64
    [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-arm64

    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    ```

#### Create a Cluster:
- You can create a cluster either by running a single-node setup:
    ```sh
    kind create cluster --image kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f --name cka-cluster-1
    ```

- Or by preparing a YAML configuration for a multi-node setup:

    **1. Create a YAML file describing the cluster:**
    ```yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
      - role: control-plane
      - role: control-plane
      - role: worker
      - role: worker
      - role: worker
      - role: worker
    ```

    **2. Create the cluster using the YAML file:**
    ```sh
    kind create cluster       --image kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f       --name cka-cluster-2       --config kind-2master-4workers
    ```

#### Verify the Created Cluster:
After creating the cluster, validate its configuration using the `kubectl` CLI:

```sh
kubectl config get-clusters
kubectl config get-users
```

#### Docker View of KIND Nodes:
Since KIND uses Docker under the hood, each Kubernetes node is represented as a Docker container. Switching context via `kubectl config use-context <cluster-name>` will show the corresponding containers becoming active:

```sh
docker ps
```

#### Example output:
```
CONTAINER ID   IMAGE                    ...        NAMES
16462509a712   kindest/haproxy:...     ...        cka-cluster-2-external-load-balancer
4016000812c4   kindest/node:...        ...        cka-cluster-2-control-plane2
...
```

#### Common Commands:

```sh
kubectl config current-context
kubectl get nodes

kubectl config use-context kind-cka-cluster-1
kubectl get nodes
```

---

### 2. VM-Based Architecture – KUBEADM Kubernetes Using VAGRANT

#### The VM architecture differs from Docker:

Each VM is a full OS instance acting as a node (master or worker).  
The general flow:
1. Install Kubeadm on the main master node and run `kubeadm init`.
2. Create a token to allow other nodes to join.
3. Other nodes (including additional masters) join using this token.

I used **Vagrant** to automate both VM creation and the Kubeadm setup process.

---

#### 1. VM Setup

You need a VM platform like **VirtualBox**, **VMware**, or **Hyper-V** that supports Vagrant.

#### Folder structure:
```
k8s-vmware-cluster/
├── Vagrantfile
├── common.sh
├── master.sh
├── worker.sh
└── disable-swap.sh
```

---

#### 2. Vagrant Installation

Ensure you're running on a system with a hypervisor (macOS, Windows, Linux).  
**Do not run Vagrant-based VMs on WSL.**

- Install Vagrant:  
  Follow [Vagrant installation instructions](https://developer.hashicorp.com/vagrant/docs/installation)

- For VMware users:  
  Install the [vagrant-vmware-desktop plugin](https://github.com/hashicorp/vagrant-vmware-desktop)

---

#### 3. Vagrantfile – VM Orchestration

Each VM is provisioned with common resources and then initialized using shell scripts.

#### Master Node:
```ruby
config.vm.define "master-node" do |node_config|
  node_config.vm.hostname = "master-node"
  node_config.vm.network "private_network", ip: "192.168.56.10"
  node_config.vm.provision "shell", path: "common.sh"
  node_config.vm.provision "shell", path: "master.sh"
  node_config.vm.provision "shell", path: "disable-swap.sh", run: "always"
end
```

In `master.sh`, the following happens:
- Runs `kubeadm init`
- Generates the `join.sh` script containing the token
- Other nodes will use this script to join the cluster

---

#### Worker Node:

```ruby
config.vm.define "worker-node-1" do |node_config|
  node_config.vm.hostname = "worker-node-1"
  node_config.vm.network "private_network", ip: "192.168.56.11"
  node_config.vm.provision "shell", path: "common.sh"
  node_config.vm.provision "shell", path: "worker.sh"
  node_config.vm.provision "shell", path: "disable-swap.sh", run: "always"
end
```

- The worker script waits for `join.sh` to be generated by the master and then executes it.

```sh
# Wait for join.sh
for i in {1..30}; do
  if [ -f /vagrant/join.sh ]; then
    break
  fi
  echo "[$(date '+%T')] Waiting for /vagrant/join.sh... (try $i/30)"
  sleep 10
  if [ "$i" == "30" ]; then
    echo "Timeout waiting for /vagrant/join.sh"
    exit 1
  fi
done
```
---

#### SWAP Management:

Kubernetes requires swap to be disabled.  
Even though `common.sh` disables swap on boot, VM restarts may re-enable it.

#### Ensure swap is disabled **always**:
```ruby
node_config.vm.provision "shell", path: "disable-swap.sh", run: "always"
```

---

## Summary

### Both KIND and KUBEADM architectures achieve the same goal with different approaches:

#### KIND:
- Simple and fast
- Uses Docker containers
- Best for development or sandbox use


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/9vyjy3k98nygtrvglcms.png)




#### KUBEADM on VMs:
- Production-grade realism
- Full control over networking, bootstrapping, and configuration
- Greater complexity and overhead


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/gbc9xqug0jfq2m6ozh1k.png)





#### Both setups follow a similar underlying flow:
1. crations of master node 
  -  + container-D
  -  + contrl plan components 
  -  + kubeadm & kubeproxy (since the control plan components are executed inside pods after all ...)
2. creation of worker nodes 
  -  + container-D
  -  + kubeproxy + kubeadm (since this are the worker node processes )
3. join the workers to the master by using kubeadm join (with the master token generated at master process)




![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hndz9kh749l4sx51drpu.png)




---

## SOME KIND EXECUTIONS : 

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