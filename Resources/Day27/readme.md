# Day 27/40 - Setup a Multi Node Kubernetes Cluster Using Kubeadm

## Check out the video below for Day27 👇

[![Day 27/40 - Setup a Multi Node Kubernetes Cluster Using Kubeadm ](https://img.youtube.com/vi/WcdMC3Lj4tU/sddefault.jpg)](https://youtu.be/WcdMC3Lj4tU)

> Note: The video installs Kubernetes 1.29 with containerd 1.7, which are both end of life now. The commands below have been updated to install Kubernetes **1.36** with containerd 2.x, so that you can practise the upgrade to **1.37** (the version used in the CKA exam as of November 2026) in the Day 34 task. The flow of the steps is the same as in the video, only the version numbers are different. Kubernetes 1.36 and later need containerd 2.x and a Linux distribution that uses cgroup v2, such as Ubuntu 22.04 or 24.04.

#### What is kubeadm
`kubeadm` is a tool to bootstrap the Kubernetes cluster. It generates the certificates, starts the control plane components (API server, etcd, controller manager, scheduler) as static pods, and prints the command that the worker nodes use to join the cluster.

kubeadm does not install the container runtime, the kubelet, kubectl or the CNI plugin for you. You install the container runtime, `kubeadm`, `kubelet` and `kubectl` on every node before you run `kubeadm init`, and you install the CNI plugin after it.

### Ways to install Kubernetes

![image](https://github.com/user-attachments/assets/5391de53-36bc-4574-81cf-4b1fefbda9e3)

>Note: In this demo, we will be installing Kubernetes on VMs on the cloud (self-managed)

### Steps to set up the Kubernetes cluster

![image](https://github.com/user-attachments/assets/e0943ad5-2d13-4128-8147-1ef644c62955)


>Note: If you are using a Mac with an Apple silicon chip, Multipass is the recommended choice as VirtualBox has some compatibility issues, or you can spin up virtual machines on the cloud and use those. On an ARM machine, replace `amd64` with `arm64` in the download URLs below.

### Minimum requirements
- 3 VMs with Ubuntu 22.04 or 24.04: 1 control plane node (called the master node in the video) and 2 worker nodes
- 2 CPUs and 2 GB RAM or more on the control plane node
- Full network connectivity between all the nodes, and a unique hostname on each node

**If you are using AWS EC2 servers, you need to allow specific traffic on specific ports as below**

1) Provision 3 VMs, 1 Master, and 2 Worker nodes.
2) Create 2 security groups, attach 1 to the master and the other to the two worker nodes using the below details.
https://kubernetes.io/docs/reference/networking/ports-and-protocols/

![image](https://github.com/user-attachments/assets/58d66bcb-ed00-453f-99b2-8df9f4393cac)


3) If you are using AWS EC2, you need to disable the **source destination check** for the VMs using the [doc](https://docs.aws.amazon.com/vpc/latest/userguide/work-with-nat-instances.html#EIP_Disable_SrcDestCheck)

### Run the below steps on the Master VM
1) SSH into the Master EC2 server

2) Disable swap using the below commands
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```
3) Forwarding IPv4 and letting iptables see bridged traffic

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Verify that the br_netfilter, overlay modules are loaded by running the following commands:
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running the following command:
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

4) Install container runtime

```bash
curl -LO https://github.com/containerd/containerd/releases/download/v2.3.6/containerd-2.3.6-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-2.3.6-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/v2.3.6/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Check that the systemd cgroup driver is enabled. This must print "SystemdCgroup = true"
grep SystemdCgroup /etc/containerd/config.toml

# Check that containerd service is up and running
systemctl status containerd
```

5) Install runc

```bash
curl -LO https://github.com/opencontainers/runc/releases/download/v1.5.2/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

6) Install the CNI plugins

```bash
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.9.1/cni-plugins-linux-amd64-v1.9.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.9.1.tgz
```

7) Install kubeadm, kubelet and kubectl

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm version
kubelet --version
kubectl version --client
```
>Note: Each Kubernetes minor version has its own apt repository. The `v1.36` in the two URLs above decides which minor version gets installed, and the install command picks the latest 1.36 patch from that repository. We are installing 1.36 here so that in one of the later tasks we can upgrade the cluster to 1.37.

8) Configure `crictl` to work with `containerd`

```bash
sudo crictl config runtime-endpoint unix:///run/containerd/containerd.sock
```

9) Initialize the control plane

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=<private-ip-of-master-node> --node-name master
```
>Note: Replace `<private-ip-of-master-node>` with the private IP address of this VM (`hostname -I` shows it). Copy the `kubeadm join` command that is printed at the end of the output to a notepad, we will use it later on the worker nodes.

>Note: `192.168.0.0/16` is the default pod network range of Calico. If your VMs are also in a `192.168.x.x` network (common with VirtualBox and home networks), pick a range that does not overlap, for example `--pod-network-cidr=10.244.0.0/16`, and set the same value for `cidr` in Calico's `custom-resources.yaml` in step 11.

10) Prepare `kubeconfig`

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
11) Install calico

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/v3_projectcalico_org.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/custom-resources.yaml -O

kubectl apply -f custom-resources.yaml
```
>Note: The first command, which installs the Calico CRDs, is a new step in recent Calico versions and is not shown in the video. The node stays in `NotReady` status until the Calico pods are running.

### Perform the below steps on both the worker nodes

- Perform steps 1-8 on both the nodes
- Run the join command that was generated in step 9 on the Master node, which is similar to the below

```bash
sudo kubeadm join <private-ip-of-master-node>:6443 --token xxxxx --discovery-token-ca-cert-hash sha256:xxx
```
- If you forgot to copy the command, you can execute the below command on the master node to generate the join command again

```bash
kubeadm token create --print-join-command
```

## Validation

If all the above steps were completed, you should be able to run `kubectl get nodes` on the master node, and it should return all the 3 nodes in ready status.

Also, make sure all the pods are up and running by using the command as below:
`kubectl get pods -A`

>If your calico-node pods are not healthy, please perform the below steps:

- Disable the source/destination checks for the master and the worker nodes.
- Add a security group rule that allows TCP port 179 (BGP) in both directions between all the nodes, and attach it to the master and the worker nodes.
- Update the ds using the command:
`kubectl set env daemonset/calico-node -n calico-system IP_AUTODETECTION_METHOD=interface=ens5`
Where ens5 is your default interface, you can confirm it by running `ip a` on all the machines
- The default value of IP_AUTODETECTION_METHOD is `first-found`, which lets Calico pick the first valid interface on each node. On machines with more than one interface it can pick the wrong one, which is why we set it explicitly above.
- Wait for some time or delete the calico-node pods and they should be up and running.
- If you are still facing the issue, you can follow the below workaround

- Install the Calico CNI add-on using the plain manifest instead of the operator and custom resources. First remove the operator-based install (`kubectl delete -f custom-resources.yaml` and then `kubectl delete -f` on the tigera-operator URL), then run
`kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/calico.yaml`

This deploys Calico in the `kube-system` namespace instead of `calico-system`.

## If something goes wrong

```bash
# kubelet logs on the node that has the problem
sudo journalctl -u kubelet -f

# containers started by the kubelet, including the control plane static pods
sudo crictl ps -a

# wipe what kubeadm did on a node and start again from step 9 (or from the join command on a worker)
sudo kubeadm reset
```
