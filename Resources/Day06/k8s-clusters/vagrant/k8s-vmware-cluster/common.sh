## 🗋 k8s-vmware-cluster/common.sh

# k8s-vmware-cluster/common.sh
#!/bin/bash

set -e

# Basic updates
sudo apt-get update -y
sudo apt-get upgrade -y

# Disable Swap (for Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Install container runtime (containerd)
sudo apt-get install -y containerd docker.io




# Check and generate containerd config if missing
if [ ! -f /etc/containerd/config.toml ]; then
    echo "[INFO] No containerd config.toml found, generating default one..."
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
fi

# Now safe to modify
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# Update containerd sandbox image to match kubeadm expectations
sudo sed -i 's|sandbox_image = ".*"|sandbox_image = "registry.k8s.io/pause:3.10"|' /etc/containerd/config.toml

# Restart containerd to apply the change
sudo systemctl restart containerd



# Enable and start services
sudo systemctl enable containerd --now
sudo systemctl enable docker --now

# Set cgroup driver to systemd
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd
EOF



# Kubernetes packages setup
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
sudo bash -c 'echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" > /etc/apt/sources.list.d/kubernetes.list'

export DEBIAN_FRONTEND=noninteractive
rm -f /etc/default/kubelet
sudo apt-get update -y
sudo apt-get install -o Dpkg::Options::="--force-confold" -y kubelet kubeadm kubectl

# Hold versions
sudo apt-mark hold kubelet kubeadm kubectl

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet