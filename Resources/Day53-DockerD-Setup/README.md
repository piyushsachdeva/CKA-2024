# Day 53 - CRI-Dockerd Installation Guide for Kubernetes

This guide provides step-by-step instructions for installing and configuring CRI-Dockerd, so that Kubernetes can use Docker Engine as its container runtime.

## Overview

The kubelet talks to a container runtime through the Container Runtime Interface (CRI). containerd and CRI-O implement the CRI themselves. Docker Engine does not. Until Kubernetes 1.23, the kubelet had an adapter for Docker built in, called dockershim. It was removed in Kubernetes 1.24. Since then, if you want to run Kubernetes on Docker Engine, you install `cri-dockerd`, an external adapter maintained by Mirantis, between the kubelet and Docker.

```
kubelet  →  CRI  →  cri-dockerd  →  Docker Engine  →  containerd  →  runc
```

Most clusters today use containerd directly. This setup is still worth knowing because "prepare a node with a given container runtime" is part of the CKA curriculum (extension interfaces: CNI, CSI, CRI).

## Prerequisites

Before starting the installation, ensure you have:

- Ubuntu 22.04 (Jammy) or 24.04 (Noble)
- Root or sudo access
- Docker Engine installed and running
- Internet connectivity for downloading packages

## Installation Steps

### Step 1: Verify Docker Installation

First, ensure Docker is installed and running on your system:

```bash
# Check Docker status
sudo systemctl status docker
docker version
```

If Docker is not installed, install it from the [official docs](https://docs.docker.com/engine/install/ubuntu/).

Optional: to run `docker` commands without `sudo`, add your user to the `docker` group and log in again. The video does this as a separate step.

```bash
sudo usermod -aG docker $USER
```

### Step 2: Download CRI-Dockerd Package

Download the CRI-Dockerd Debian package for your Ubuntu version from the official GitHub releases:

```bash
# Ubuntu 22.04 (Jammy)
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.4.9/cri-dockerd_0.4.9.3-0.ubuntu-jammy_amd64.deb

# Ubuntu 24.04 (Noble)
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.4.9/cri-dockerd_0.4.9.3-0.ubuntu-noble_amd64.deb
```

> **Note**: The video uses v0.3.16. Check the [official releases page](https://github.com/Mirantis/cri-dockerd/releases/) for the latest version and update the URL accordingly. Run `lsb_release -cs` if you are not sure which Ubuntu release you have.

### Step 3: Install CRI-Dockerd Package

Install the downloaded package using dpkg:

```bash
# Install the CRI-Dockerd package (use the file name that you downloaded)
sudo dpkg -i cri-dockerd_0.4.9.3-0.ubuntu-jammy_amd64.deb
```

If `dpkg` complains about missing dependencies, run `sudo apt-get install -f` and it will install them and finish the setup.

### Step 4: Enable and Start CRI-Dockerd Service

Enable and start the CRI-Dockerd service:

```bash
# Enable the service to start on boot and start it now
sudo systemctl enable --now cri-docker.service

# Check the service status
sudo systemctl status cri-docker.service
```

### Step 5: Configure System Parameters

Configure the required kernel parameters for Kubernetes networking:

```bash
# Load the bridge netfilter module now and on every boot
echo br_netfilter | sudo tee /etc/modules-load.d/k8s.conf
sudo modprobe br_netfilter

# Create and configure kernel parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv6.conf.all.forwarding        = 1
net.ipv4.ip_forward                 = 1
net.netfilter.nf_conntrack_max      = 131072
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

Verify that the values are applied:

```bash
sysctl net.bridge.bridge-nf-call-iptables net.ipv6.conf.all.forwarding net.ipv4.ip_forward net.netfilter.nf_conntrack_max
```

> Note: The parameter is `net.ipv6.conf.all.forwarding`, with a dot between `all` and `forwarding`. If a task gives you a list of parameters, copy the names exactly, because `sysctl --system` skips a wrong name with only a small warning.

## Verification

### Verify CRI-Dockerd Installation

Check if CRI-Dockerd is running correctly:

```bash
# Check CRI-Dockerd service status
sudo systemctl status cri-docker.service

# Check CRI-Dockerd socket status
sudo systemctl status cri-docker.socket

# Check that both are enabled to start on boot
systemctl is-enabled cri-docker.service cri-docker.socket

# View CRI-Dockerd logs
sudo journalctl -u cri-docker.service --no-pager | tail -20
```

## Use CRI-Dockerd with kubeadm

The socket of cri-dockerd is `unix:///var/run/cri-dockerd.sock`. When a node has more than one container runtime installed (Docker Engine brings its own containerd), kubeadm cannot choose on its own, so you pass the socket explicitly:

```bash
# on the control plane node
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock

# on a worker node, add the same flag to the join command
sudo kubeadm join <control-plane-ip>:6443 --token xxxxx --discovery-token-ca-cert-hash sha256:xxx --cri-socket unix:///var/run/cri-dockerd.sock

# point crictl to the same socket
sudo crictl config runtime-endpoint unix:///var/run/cri-dockerd.sock
```

After the node has joined, check which runtime each node uses in the `CONTAINER-RUNTIME` column:

```bash
kubectl get nodes -o wide
```
