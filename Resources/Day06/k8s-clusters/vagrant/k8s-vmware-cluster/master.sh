## 🗋 k8s-vmware-cluster/master.s
#!/bin/bash

set -e

# Initialize Kubernetes Master
sudo kubeadm init \
  --apiserver-advertise-address=192.168.56.10 \
  --pod-network-cidr=10.244.0.0/16

# Install Flannel network plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Generate join command
kubeadm token create --print-join-command > /vagrant/join.sh

echo "[INFO] Setting up kubeconfig for vagrant user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config