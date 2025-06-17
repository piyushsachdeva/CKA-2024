# Infrastructure setup

- 1 VPC    ex. (VPC CIDR: 10.0.0.0/16)
- 1 subnet for all the nodes (someone can use multiple subnets for  high availability) with internet
- 3 Security groups (master-sg,load-balancer-sg, worker-sg)

master nodes security group 

![image](https://github.com/user-attachments/assets/e29bf4e2-6f16-4c7c-b3d9-4f8075766d14)

![image](https://github.com/user-attachments/assets/d77055dd-199a-4971-85a2-87c4d9866f77)


worker node security group

![image](https://github.com/user-attachments/assets/342b8fef-84de-496f-aa9f-ad2fa3a22dd5)


load balancer security group

![image](https://github.com/user-attachments/assets/23f7d21a-1870-47bb-901c-12125ad5f190)


![image](https://github.com/user-attachments/assets/5ccc03aa-cb80-490c-8013-9d8621a75f45)


- 2 machines for master, ubuntu 16.04+, 2 CPU, 2 GB RAM, 10 GB storage
- 2 machines for worker, ubuntu 16.04+, 1 CPU, 2 GB RAM, 10 GB storage
- 1 machine for load balancer, ubuntu 16.04+, 1 CPU, 2 GB RAM, 10 GB storage

# Load Balancer VM

- Login to the loadbalancer node
- Switch as root -  `sudo -i`
- Update your repository and your system

```
sudo apt-get update && sudo apt-get upgrade -y
```

- Install haproxy

```
sudo apt-get install haproxy -y
```

- Edit haproxy configuration

```
sudo vi /etc/haproxy/haproxy.cfg
```

make sure to use private ips for all the communication as we are using as we are going to perform all the communication within the vpc only 

```jsx

frontend kubernetes-api
         bind *:6443
         mode tcp
         option tcplog
         default_backend kube-master-nodes
```

### What this means:

- **`frontend kubernetes-api`**
    
    This names the frontend block `kubernetes-api`. It's just an identifier — you could call it anything, but naming it clearly helps for readability.
    
- **`bind *:6443`**
    
    This tells HAProxy to listen for incoming connections on **port 6443** on **all interfaces** (`*` means all available IPs on the server).
    
    - Port **6443** is the standard Kubernetes API port.
    - This is the port `kubeadm` and `kubectl` will connect to.
- **`default_backend kube-masters`**
    
    Any connection received on this frontend will be forwarded to the **`kube-masters` backend** (defined in the next block).
    

💡 This block is essentially the **public-facing listener** for Kubernetes API requests

```jsx
backend kube-master-nodes
        mode tcp
        balance roundrobin
        option tcp-check
        default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100

    
        server master1 <private-ip of master node 01>:6443 check
        server master2 <private-ip of master node 02>:6443 check
```

### What this means:

- **`backend kube-masters`**
    
    This names the backend pool `kube-masters`. This matches the `default_backend` in the frontend section.
    
- **`mode tcp`**
    
    HAProxy operates in **TCP mode** (not HTTP). The Kubernetes API server uses raw TCP (HTTPS), so this mode is required.
    
- **`balance roundrobin`**
    
    Load balances incoming connections using **round-robin strategy**:
    
    - First request → master1
    - Second request → master2
    - Third → master3
    - Then it repeats...
    
    This spreads the load evenly across your control plane nodes.
    
- **`option tcp-check`**
    
    Enables **health checks** using TCP connection attempts. If HAProxy cannot make a TCP connection to a node’s port 6443, it considers that node **unhealthy** and removes it from the rotation.
    
- **`default-server inter 5s fall 3 rise 2`**
    
    These are health check tuning parameters:
    
    - `inter 10s`: Check every 10s.
    - `downinter 5s`: If down, recheck every 5s.
    - `rise 2`: Need 2 successful checks to be considered healthy.
    - `fall 2`: 2 failed checks mark the server as down.
    - `slowstart 60s`: After recovery, slowly ramp up traffic over 60s.
    - `maxconn 250`: Max 250 connections.
    - `maxqueue 256`: Queue limit.
    - `weight 100`: Default weight for load balancing.

final output 

```jsx
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

frontend kubernetes-api
         bind *:6443
         mode tcp
         option tcplog
         default_backend kube-master-nodes

backend kube-master-nodes
        mode tcp
        balance roundrobin
        option tcp-check
        default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100

    
        server master1 <private-ip of master node 01>:6443 check
        server master2 <private-ip of master node 02>:6443 check
```

make sure to replace the placeholders with private ip of master instances 

## After Configuration

1. **Save and Restart HAProxy**:
    
    ```bash
    sudo systemctl restart haproxy
    ```
    
2. **Enable at boot**:
    
    ```bash
    sudo systemctl enable haproxy
    ```
    
3.  Check if the port 6443 is open and responding for haproxy connection or not

```jsx
nc -v localhost 6443

```

you will see a response like 

```jsx
Connection to localhost (127.0.0.1) 6443 port [tcp/*] succeeded!`
```

<aside>
💡

**Note** If you see failures for master1 and master2 connectivity, you can ignore them for time being as we have not yet installed anything on the servers.

</aside>

# Run on Any  master node it will act as leader

**Run the below steps on the Master VM**

1. SSH into the Master EC2 server
    1. Do `sudo -i`
2. Disable Swap using the below commands

```jsx
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

1. Forwarding IPv4 and letting iptables see bridged traffic

```jsx
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

1.  Install container runtime

```jsx
curl -LO https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Check that containerd service is up and running
systemctl status containerd
```

1. Install runc

```jsx
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

1. Install CNI plugin

```jsx

curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.0.tgz
```

1. Install kubeadm,kublet and kubectl

```jsx
# Step 1: Update system and install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Step 2: Add Kubernetes apt repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 3: Update package list
sudo apt-get update

# Step 4: Install specific Kubernetes versions (adjust version if needed)
sudo apt-get install -y kubelet=1.33.0-1.1 kubeadm=1.33.0-1.1 kubectl=1.33.0-1.1 --allow-downgrades --allow-change-held-packages

# Step 5: Hold the package versions to prevent upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Step 6: Verify installation
kubeadm version
kubelet --version
kubectl version --client

```

check kubelet in properly installed and enabled or not 

```jsx
systemctl status kubelet
```

Initialize  kubeadm

```jsx
kubeadm init \
  --control-plane-endpoint "<load-balancer-private-ip>:6443" \
  --upload-certs \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=<private-ip-of-this-ec2-instance>

```

final command will look like the below 

![image](https://github.com/user-attachments/assets/c885d24d-4d4b-4dc0-849c-3962d63260a5)

To start using your cluster, you need to run the following as a regular user:

`mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config`

Alternatively, if you are the root user, you can run:

`export KUBECONFIG=/etc/kubernetes/admin.conf`

now you can do `kubectl get nodes` to see you control plane node is okay or not if you see a not ready status now, it is normal as we need to install and configure cni plugin to start intra pod communication 

 

![image](https://github.com/user-attachments/assets/ce616d86-b716-4f71-bef3-1ccb475b2496)

this command will generate two different type of join tokens 

1. Join token for other master nodes to join the control plane 

![image](https://github.com/user-attachments/assets/afe7ddb3-a7f6-42d6-b076-77724c9d5032)

1. Join token for the worker node to join the worker plane 

![image](https://github.com/user-attachments/assets/e4d79bd0-0b08-44ca-a884-40d17f596b0e)

copy and save both the commands this will be needed in the future

now install calico (network addon ) to start pod to pod communication

```jsx
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O

kubectl apply -f custom-resources.yaml
```

will see a output like this 

![image](https://github.com/user-attachments/assets/5b2bc24a-1598-47e0-85f1-56e3da5b2a58)

after this if you do `kubectl get nodes` you will see your control-plnae node is ready state 

 

![image](https://github.com/user-attachments/assets/e0a36c98-70d9-4071-bb3a-8cd69ca22dad)

all done on the leader control plane node

# Run steps below on the other control plane nodes

1. SSH into the Master EC2 server
    1. Do `sudo -i`
2. Disable Swap using the below commands

```jsx
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

1. Forwarding IPv4 and letting iptables see bridged traffic

```jsx
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

1.  Install container runtime

```jsx
curl -LO https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Check that containerd service is up and running
systemctl status containerd
```

1. Install runc

```jsx
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

1. Install CNI plugin

```jsx

curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.0.tgz
```

1. Install kubeadm,kublet and kubectl

```jsx
# Step 1: Update system and install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Step 2: Add Kubernetes apt repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 3: Update package list
sudo apt-get update

# Step 4: Install specific Kubernetes versions (adjust version if needed)
sudo apt-get install -y kubelet=1.33.0-1.1 kubeadm=1.33.0-1.1 kubectl=1.33.0-1.1 --allow-downgrades --allow-change-held-packages

# Step 5: Hold the package versions to prevent upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Step 6: Verify installation
kubeadm version
kubelet --version
kubectl version --client

```

check kubelet in properly installed and enabled or not 

```jsx
systemctl status kubelet
```

now use the join command to join the control plane leader node  (I told you to save it in the leader node setup phase )

![image](https://github.com/user-attachments/assets/55a35340-9935-4727-8a1d-6297ba9f05cc)

you will see a message like this if everything goes right

This node has joined the cluster and a new control plane instance was created:

- Certificate signing request was sent to apiserver and approval was received.
- The Kubelet was informed of the new secure connection details.
- Control plane label and taint were applied to the new node.
- The Kubernetes control plane instances scaled up.
- A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

Run `'kubectl get nodes`' to see this node join the cluster.

![image](https://github.com/user-attachments/assets/e6ec6e0f-d6e1-4e92-8b19-b346abb01911)

now you have two master nodes in ready states in the control plane now lets setup the worker nodes 

# Woker plane setup

login to both the worker nodes and run all the commanders below 

1. SSH into the Master EC2 server
    1. Do `sudo -i`
2. Disable Swap using the below commands

```jsx
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

1. Forwarding IPv4 and letting iptables see bridged traffic

```jsx
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

1.  Install container runtime

```jsx
curl -LO https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Check that containerd service is up and running
systemctl status containerd
```

1. Install runc

```jsx
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

1. Install CNI plugin

```jsx

curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.0.tgz
```

1. Install kubeadm,kublet and kubectl

```jsx
# Step 1: Update system and install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Step 2: Add Kubernetes apt repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 3: Update package list
sudo apt-get update

# Step 4: Install specific Kubernetes versions (adjust version if needed)
sudo apt-get install -y kubelet=1.33.0-1.1 kubeadm=1.33.0-1.1 kubectl=1.33.0-1.1 --allow-downgrades --allow-change-held-packages

# Step 5: Hold the package versions to prevent upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Step 6: Verify installation
kubeadm version
kubelet --version
kubectl version --client

```

check kubelet in properly installed and enabled or not 

```jsx
systemctl status kubelet
```

now use the previously generated commands to join the worker nodes to the control plane 

the command looks like this 

![image](https://github.com/user-attachments/assets/8386eaa5-aea6-45b2-a104-baf4502faa62)

  if everything goes right you will a message like this

This node has joined the cluster:

- Certificate signing request was sent to apiserver and a response was received.
- The Kubelet was informed of the new secure connection details.

Run '`kubectl get nodes`' on the control-plane to see this node join the cluster.

![image](https://github.com/user-attachments/assets/4cac178f-6216-4a93-b78e-27419883210c)

let see if our load balancer is working fine or not 

```jsx
 sudo journalctl -u haproxy -f

```

you will see a output like this 

```jsx
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51630 [24/May/2025:21:02:36.367] kubernetes-api kube-master-nodes/master1 1/1/62 2744 -- 10/10/9/5/0 0/0
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51632 [24/May/2025:21:02:36.367] kubernetes-api kube-master-nodes/master2 1/1/67 2707 -- 9/9/8/3/0 0/0
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51622 [24/May/2025:21:02:36.367] kubernetes-api kube-master-nodes/master2 1/1/68 2707 -- 8/8/7/2/0 0/0
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51640 [24/May/2025:21:02:36.382] kubernetes-api kube-master-nodes/master1 1/0/54 2707 -- 7/7/6/4/0 0/0
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51652 [24/May/2025:21:02:36.382] kubernetes-api kube-master-nodes/master2 1/0/54 2744 -- 6/6/5/1/0 0/0
May 24 21:02:37 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51588 [24/May/2025:21:02:36.354] kubernetes-api kube-master-nodes/master1 1/0/939 21869 -- 6/6/5/4/0 0/0
May 24 21:02:37 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51484 [24/May/2025:21:02:34.968] kubernetes-api kube-master-nodes/master1 1/0/2394 8113 -- 6/6/5/3/0 0/0
May 24 21:02:37 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:36926 [24/May/2025:21:02:37.339] kubernetes-api kube-master-nodes/master2 1/0/24 7446 -- 5/5/4/1/0 0/0
May 24 21:04:06 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51498 [24/May/2025:21:02:36.291] kubernetes-api kube-master-nodes/master2 1/0/90112 7989 -- 5/5/4/0/0 0/0
May 24 21:04:53 ip-10-0-0-10 haproxy[19490]: 10.0.0.49:36898 [24/May/2025:21:04:53.770] kubernetes-api kube-master-nodes/master2 1/0/19 15526 -- 5/5/4/0/0 0/0

```

and all set now your multi control node cluster with stacked etcd is ready you can try provision a pod now

```jsx
**kubectl run nginx --image=nginx --port=80**
```

# **Configure Your Local kubeconfig**

You need a valid `kubeconfig` file that points to the HAProxy public IP.

On your **local PC**:

### Step 1: Copy the `admin.conf` from any control plane node:

From the control plane node:

```jsx
cat /etc/kubernetes/admin.conf
```

Copy the contents, or use `scp`:

```bash
scp -i your-key.pem ec2-user@<control-plane-ip>:/etc/kubernetes/admin.conf ~/haproxy-kubeconfig.yaml
```

### Step 2: Edit the config:

In the copied config file (`haproxy-kubeconfig.yaml`):

- Replace:
    
    ```yaml
    
    server: https://<control-plane-private-ip>:6443
    ```
    
    with:
    
    ```yaml
    server: https://<your-haproxy-public-ip>:6443
    ```
    
- Save the file.

---

## 4. **Test the Connection**

On your **local PC**, run:

```bash

KUBECONFIG=~/haproxy-kubeconfig.yaml kubectl get nodes
```

### ✅ If output shows your cluster nodes:

You’re connected successfully from outside the VPC via HAProxy.
