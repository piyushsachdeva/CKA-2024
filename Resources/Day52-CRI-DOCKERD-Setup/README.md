# CRI-Dockerd Installation Guide for Kubernetes

This guide provides step-by-step instructions for installing and configuring CRI-Dockerd as a container runtime for Kubernetes clusters.

## Overview

CRI-Dockerd is a Container Runtime Interface (CRI) implementation that allows Kubernetes to use Docker Engine as the container runtime. This is particularly useful for maintaining Docker compatibility in Kubernetes environments.

## Prerequisites

Before starting the installation, ensure you have:

- Ubuntu 22.04 (Jammy) or compatible Linux distribution
- Root or sudo access
- Docker Engine installed and running
- Internet connectivity for downloading packages

## Installation Steps

### Step 1: Verify Docker Installation

First, ensure Docker is installed and running on your system:

```bash
# Check Docker status
sudo systemctl status docker
```

### Step 2: Create Docker Group

Create the docker group and add your user to it:

```bash
# Create docker group (if it doesn't exist)
sudo groupadd docker

# Add current user to docker group
sudo usermod -aG docker $USER

# Add root user to docker group
sudo usermod -aG docker root
```

### Step 3: Download CRI-Dockerd Package

Download the latest CRI-Dockerd Debian package from the official GitHub releases:

```bash
# Download the CRI-Dockerd package
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd_0.3.16.3-0.ubuntu-jammy_amd64.deb
```

> **Note**: Check the [official releases page](https://github.com/Mirantis/cri-dockerd/releases/) for the latest version and update the URL accordingly.

### Step 4: Install CRI-Dockerd Package

Install the downloaded package using dpkg:

```bash
# Install the CRI-Dockerd package
sudo dpkg -i cri-dockerd_0.3.16.3-0.ubuntu-jammy_amd64.deb
```

### Step 5: Enable and Start CRI-Dockerd Service

Enable and start the CRI-Dockerd service:

```bash
# Enable CRI-Dockerd service to start on boot
sudo systemctl enable --now cri-docker.service

# Start the CRI-Dockerd service
sudo systemctl start cri-docker.service

# Check the service status
sudo systemctl status cri-docker.service
```

### Step 7: Configure System Parameters

Configure the required kernel parameters for Kubernetes networking:

```bash
# Create and configure kernel parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.netfilter.nf_conntrack_max  = 131072
net.ipv6.conf.allforwarding = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Reload systemd daemon
sudo systemctl daemon-reload
```

## Verification

### Verify CRI-Dockerd Installation

Check if CRI-Dockerd is running correctly:

```bash
# Check CRI-Dockerd service status
sudo systemctl status cri-docker.service

# Check CRI-Dockerd socket status
sudo systemctl status cri-docker.socket

# View CRI-Dockerd logs
sudo journalctl -u cri-docker.service -f
```
