# Day 55 - Highly Available Control Plane with kubeadm (stacked etcd)

In this guide we build a Kubernetes cluster with more than one control plane node. A load balancer (HAProxy) sits in front of the API servers, and every control plane node also runs an etcd member (the "stacked etcd" topology).

> Note: The video builds the cluster with **2** control plane nodes and Kubernetes 1.33. Two things have been updated in the steps below:
> - The commands install Kubernetes 1.37 with containerd 2.x.
> - The guide recommends **3** control plane nodes. etcd needs a majority of its members (a quorum) to keep working. With 2 members the majority is 2, so if either node goes down, etcd stops and the cluster with it. Two control plane nodes are fine to learn the join process, but they do not give you high availability. With 3 members the cluster survives the loss of one node, and with 5 members the loss of two.

```
                     ┌──────────────────┐
  kubectl, kubelets ─►  Load balancer   │
                     │  (HAProxy :6443) │
                     └────────┬─────────┘
            ┌─────────────────┼─────────────────┐
     ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
     │  master1    │   │  master2    │   │  master3    │
     │  apiserver  │   │  apiserver  │   │  apiserver  │
     │  etcd       │◄─►│  etcd       │◄─►│  etcd       │
     └─────────────┘   └─────────────┘   └─────────────┘
```

# Infrastructure setup

- 1 VPC    ex. (VPC CIDR: 10.0.0.0/16)
- 1 subnet for all the nodes (you can use multiple subnets in different availability zones for higher availability) with internet access
- 3 Security groups (master-sg, load-balancer-sg, worker-sg)

master nodes security group 

![image](https://github.com/user-attachments/assets/e29bf4e2-6f16-4c7c-b3d9-4f8075766d14)

![image](https://github.com/user-attachments/assets/d77055dd-199a-4971-85a2-87c4d9866f77)


worker node security group

![image](https://github.com/user-attachments/assets/342b8fef-84de-496f-aa9f-ad2fa3a22dd5)


load balancer security group

![image](https://github.com/user-attachments/assets/23f7d21a-1870-47bb-901c-12125ad5f190)


![image](https://github.com/user-attachments/assets/5ccc03aa-cb80-490c-8013-9d8621a75f45)


- 3 machines for master (2 if you only want to follow the video), Ubuntu 22.04 or 24.04, 2 CPU, 2 GB RAM, 10 GB storage
- 2 machines for worker, Ubuntu 22.04 or 24.04, 1 CPU, 2 GB RAM, 10 GB storage
- 1 machine for load balancer, Ubuntu 22.04 or 24.04, 1 CPU, 2 GB RAM, 10 GB storage

The ports that must be open between the machines are listed in the [Kubernetes docs](https://kubernetes.io/docs/reference/networking/ports-and-protocols/). On top of the usual ports, the control plane nodes must reach each other on 2379-2380 (etcd), and the load balancer must reach every control plane node on 6443.

# Load Balancer VM

- Login to the loadbalancer node
- Update your repository and your system

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

- Install haproxy

```bash
sudo apt-get install haproxy -y
```

- Edit haproxy configuration

```bash
sudo vi /etc/haproxy/haproxy.cfg
```

Keep the `global` and `defaults` sections that are already in the file, and add the two blocks below at the end. Make sure to use the private IPs of the master nodes, as all the communication happens inside the VPC.

```
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
        server master3 <private-ip of master node 03>:6443 check
```

### What the frontend block means:

- **`frontend kubernetes-api`**
    
    This names the frontend block `kubernetes-api`. It's just an identifier — you could call it anything, but naming it clearly helps for readability.
    
- **`bind *:6443`**
    
    This tells HAProxy to listen for incoming connections on **port 6443** on **all interfaces** (`*` means all available IPs on the server).
    
    - Port **6443** is the standard Kubernetes API port.
    - This is the port `kubeadm`, `kubectl` and the kubelets will connect to.
- **`default_backend kube-master-nodes`**
    
    Any connection received on this frontend will be forwarded to the **`kube-master-nodes` backend** (defined in the next block). The name here must be the same as the name of the backend block.
    

💡 This block is the listener for Kubernetes API requests.

### What the backend block means:

- **`backend kube-master-nodes`**
    
    This names the backend pool `kube-master-nodes`. This matches the `default_backend` in the frontend section.
    
- **`mode tcp`**
    
    HAProxy operates in **TCP mode** (not HTTP). It passes the encrypted HTTPS traffic of the Kubernetes API through without opening it, so the TLS connection is still between the client and the API server.
    
- **`balance roundrobin`**
    
    Load balances incoming connections using the **round-robin strategy**:
    
    - First connection → master1
    - Second connection → master2
    - Third connection → master3
    - Then it repeats...
    
    This spreads the load evenly across your control plane nodes.
    
- **`option tcp-check`**
    
    Enables **health checks** using TCP connection attempts. If HAProxy cannot make a TCP connection to a node’s port 6443, it considers that node **unhealthy** and removes it from the rotation.
    
- **`default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100`**
    
    These are health check tuning parameters:
    
    - `inter 10s`: Check every 10s.
    - `downinter 5s`: If down, recheck every 5s.
    - `rise 2`: Need 2 successful checks to be considered healthy.
    - `fall 2`: 2 failed checks mark the server as down.
    - `slowstart 60s`: After recovery, slowly ramp up traffic over 60s.
    - `maxconn 250`: Max 250 connections.
    - `maxqueue 256`: Queue limit.
    - `weight 100`: Default weight for load balancing.

If you are building the cluster with 2 master nodes as in the video, leave out the `server master3` line.

## After Configuration

1. **Check the configuration for syntax errors**:

    ```bash
    sudo haproxy -c -f /etc/haproxy/haproxy.cfg
    ```

2. **Restart HAProxy**:
    
    ```bash
    sudo systemctl restart haproxy
    ```
    
3. **Enable at boot**:
    
    ```bash
    sudo systemctl enable haproxy
    ```
    
4.  Check if port 6443 is open and HAProxy is accepting connections

    ```bash
    nc -v localhost 6443
    ```

    you will see a response like 

    ```
    Connection to localhost (127.0.0.1) 6443 port [tcp/*] succeeded!
    ```

💡 **Note** If the HAProxy logs show the master servers as down, you can ignore that for the time being, as we have not yet installed anything on those servers.

> Note: In this setup, the load balancer VM is itself a single point of failure. For a production cluster, use a managed cloud load balancer or two HAProxy machines that share a virtual IP with keepalived.

# Prepare every node (all the master and worker nodes)

Run the steps of this section on **all** the master nodes and **all** the worker nodes. These are the same steps as in the [Day27](Day27/readme.md) guide.

1. SSH into the node
2. Disable swap using the below commands

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

3. Forwarding IPv4 and letting iptables see bridged traffic

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

4. Install container runtime

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

# This must print "SystemdCgroup = true"
grep SystemdCgroup /etc/containerd/config.toml

# Check that containerd service is up and running
systemctl status containerd
```

5. Install runc

```bash
curl -LO https://github.com/opencontainers/runc/releases/download/v1.5.2/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

6. Install the CNI plugins

```bash
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.9.1/cni-plugins-linux-amd64-v1.9.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.9.1.tgz
```

7. Install kubeadm, kubelet and kubectl

```bash
# Step 1: Update system and install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Step 2: Add Kubernetes apt repository
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.37/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.37/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 3: Update package list
sudo apt-get update

# Step 4: Install the latest 1.37 patch version
sudo apt-get install -y kubelet kubeadm kubectl

# Step 5: Hold the package versions to prevent upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Step 6: Verify installation
kubeadm version
kubelet --version
kubectl version --client
```

Check that the kubelet service is installed and enabled

```bash
systemctl status kubelet
```

At this point the kubelet restarts every few seconds, because it has no configuration yet. That is expected. It settles down after `kubeadm init` or `kubeadm join`.

# Run on the first master node

Initialize the cluster with kubeadm

```bash
sudo kubeadm init \
  --control-plane-endpoint "<load-balancer-private-ip>:6443" \
  --upload-certs \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=<private-ip-of-this-ec2-instance> \
  --apiserver-cert-extra-sans=<load-balancer-public-ip>
```

- `--control-plane-endpoint` is the address of the load balancer. Every node and every kubeconfig will use this address to reach the API server, in place of the IP of a single master node. kubeadm does not support turning a cluster that was created without it into a highly available one later, so it must be set at `kubeadm init`.
- `--upload-certs` stores the control plane certificates, encrypted, in a Secret in the cluster, so that the other master nodes can download them when they join. Without it, you would have to copy the certificates to every master node by hand.
- `--apiserver-cert-extra-sans` adds the public IP of the load balancer to the certificate of the API server. You need it only if you want to use `kubectl` from outside the VPC (last section of this guide).

the final command will look like the below 

![image](https://github.com/user-attachments/assets/c885d24d-4d4b-4dc0-849c-3962d63260a5)

To start using your cluster, you need to run the following as a regular user:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Alternatively, if you are the root user, you can run:

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
```

Now you can run `kubectl get nodes` to see your control plane node. If you see the `NotReady` status at this point, it is normal, as we still need to install the CNI plugin for pod networking.

![image](https://github.com/user-attachments/assets/ce616d86-b716-4f71-bef3-1ccb475b2496)

The output of `kubeadm init` has two different join commands 

1. The join command for the other master nodes, to join the control plane. It has the extra flags `--control-plane` and `--certificate-key`

![image](https://github.com/user-attachments/assets/afe7ddb3-a7f6-42d6-b076-77724c9d5032)

2. The join command for the worker nodes

![image](https://github.com/user-attachments/assets/e4d79bd0-0b08-44ca-a884-40d17f596b0e)

Copy and save both the commands, they will be needed in the next steps.

Now install calico (the network add-on) for pod to pod communication

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/v3_projectcalico_org.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/custom-resources.yaml -O

kubectl apply -f custom-resources.yaml
```

you will see an output like this 

![image](https://github.com/user-attachments/assets/5b2bc24a-1598-47e0-85f1-56e3da5b2a58)

After this, if you run `kubectl get nodes`, you will see your control plane node in the Ready state

![image](https://github.com/user-attachments/assets/e0a36c98-70d9-4071-bb3a-8cd69ca22dad)

All done on the first control plane node.

# Run on the other master nodes

Make sure you have completed the "Prepare every node" section on these nodes.

Now use the control plane join command that you saved earlier, with `sudo`. Run it on one master node at a time and wait for it to finish before you start the next one.

![image](https://github.com/user-attachments/assets/55a35340-9935-4727-8a1d-6297ba9f05cc)

```bash
sudo kubeadm join <load-balancer-private-ip>:6443 --token xxxxx \
  --discovery-token-ca-cert-hash sha256:xxx \
  --control-plane --certificate-key xxx \
  --apiserver-advertise-address=<private-ip-of-this-ec2-instance>
```

You will see a message like this if everything goes right

This node has joined the cluster and a new control plane instance was created:

- Certificate signing request was sent to apiserver and approval was received.
- The Kubelet was informed of the new secure connection details.
- Control plane label and taint were applied to the new node.
- The Kubernetes control plane instances scaled up.
- A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Run `kubectl get nodes` to see this node join the cluster.

![image](https://github.com/user-attachments/assets/e6ec6e0f-d6e1-4e92-8b19-b346abb01911)

> Note: The certificates that `--upload-certs` stored in the cluster are deleted after 2 hours, and the join token expires after 24 hours. If you add a master node later, create new ones on an existing master node:
>
> ```bash
> # prints a new certificate key
> sudo kubeadm init phase upload-certs --upload-certs
>
> # prints a new join command. Add "--control-plane --certificate-key <key>" to it for a master node
> sudo kubeadm token create --print-join-command
> ```

# Worker node setup

Make sure you have completed the "Prepare every node" section on both the worker nodes.

Now use the worker join command that you saved earlier, with `sudo`, to join the worker nodes to the cluster 

the command looks like this 

![image](https://github.com/user-attachments/assets/8386eaa5-aea6-45b2-a104-baf4502faa62)

  if everything goes right you will see a message like this

This node has joined the cluster:

- Certificate signing request was sent to apiserver and a response was received.
- The Kubelet was informed of the new secure connection details.

Run `kubectl get nodes` on the control-plane to see this node join the cluster.

![image](https://github.com/user-attachments/assets/4cac178f-6216-4a93-b78e-27419883210c)

# Verify the setup

Let's see if our load balancer is working fine. On the load balancer VM:

```bash
sudo journalctl -u haproxy -f
```

you will see an output like this, with the connections spread across the master nodes 

```
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51630 [24/May/2025:21:02:36.367] kubernetes-api kube-master-nodes/master1 1/1/62 2744 -- 10/10/9/5/0 0/0
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51632 [24/May/2025:21:02:36.367] kubernetes-api kube-master-nodes/master2 1/1/67 2707 -- 9/9/8/3/0 0/0
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51622 [24/May/2025:21:02:36.367] kubernetes-api kube-master-nodes/master2 1/1/68 2707 -- 8/8/7/2/0 0/0
May 24 21:02:36 ip-10-0-0-10 haproxy[19490]: 10.0.0.248:51640 [24/May/2025:21:02:36.382] kubernetes-api kube-master-nodes/master1 1/0/54 2707 -- 7/7/6/4/0 0/0
```

On a master node, check the control plane pods and the etcd members:

```bash
kubectl get nodes
kubectl get pods -n kube-system -o wide | grep -E "etcd|kube-apiserver|kube-scheduler|kube-controller"

# every kubeconfig points to the load balancer, not to a single master node
kubectl cluster-info

# list the etcd members (replace etcd-master1 with the name of one of your etcd pods)
kubectl -n kube-system exec etcd-master1 -- etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list -w table
```

All set. Your multi control plane cluster with stacked etcd is ready, and you can try to create a pod now

```bash
kubectl run nginx --image=nginx --port=80
```

## Test the high availability

With 3 master nodes, shut down one of them (or stop its kubelet and containerd) and run `kubectl get nodes` from another master node. The API still answers, because HAProxy has taken the failed node out of the rotation and etcd still has 2 of its 3 members. Start the node again and it rejoins on its own.

If you built the cluster with 2 master nodes and shut one of them down, `kubectl` stops working, because etcd has lost its quorum. This is the reason for the recommendation of 3 nodes at the top of this guide.

# Configure Your Local kubeconfig

You need a valid `kubeconfig` file that points to the HAProxy public IP. This works only if you passed `--apiserver-cert-extra-sans=<load-balancer-public-ip>` to `kubeadm init`, and if the security group of the load balancer allows port 6443 from your IP address.

On your **local PC**:

### Step 1: Copy the `admin.conf` from any control plane node:

`/etc/kubernetes/admin.conf` can only be read by root, so first make a copy that your SSH user can read. On the control plane node:

```bash
sudo cp /etc/kubernetes/admin.conf /tmp/admin.conf
sudo chown $(id -u):$(id -g) /tmp/admin.conf
```

Then, from your local PC, copy it with `scp` and delete the temporary copy:

```bash
scp -i your-key.pem ubuntu@<control-plane-public-ip>:/tmp/admin.conf ~/haproxy-kubeconfig.yaml
ssh -i your-key.pem ubuntu@<control-plane-public-ip> rm /tmp/admin.conf
```

### Step 2: Edit the config:

In the copied config file (`haproxy-kubeconfig.yaml`):

- Replace:
    
    ```yaml
    server: https://<load-balancer-private-ip>:6443
    ```
    
    with:
    
    ```yaml
    server: https://<your-haproxy-public-ip>:6443
    ```
    
- Save the file.

### Step 3: Test the Connection

On your **local PC**, run:

```bash
KUBECONFIG=~/haproxy-kubeconfig.yaml kubectl get nodes
```

### ✅ If the output shows your cluster nodes:

You’re connected successfully from outside the VPC via HAProxy.

If you get the error `x509: certificate is valid for ..., not <public-ip>`, the public IP of the load balancer is not in the certificate of the API server. See the note on `--apiserver-cert-extra-sans` above.

> Note: `admin.conf` gives full admin access to the cluster. Keep the file safe, and do not leave port 6443 of the load balancer open to the whole internet.
