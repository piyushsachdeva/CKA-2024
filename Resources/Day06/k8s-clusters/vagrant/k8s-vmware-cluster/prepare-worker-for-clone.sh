#!/bin/bash

# ========= Metadata =========
# Purpose: Prepare a Kubernetes worker VM for cloning
# Action: Resets Kubernetes, cleans identity, prepares minimal startup customization
# ==============================

echo "[INFO] Starting preparation for clone..."

# Reset Kubernetes node (remove certificates, configurations)
sudo kubeadm reset -f
sudo systemctl stop kubelet
sudo systemctl stop docker

# Clean CNI network configs
sudo rm -rf /etc/cni/net.d/*

# Remove Kubernetes config
sudo rm -rf $HOME/.kube
sudo rm -rf /etc/kubernetes

# Clean machine-id (for network uniqueness)
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clean DHCP leases (if you are using DHCP IPs)
sudo rm -f /var/lib/dhcp/*

# Optional: Clean logs
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s
sudo rm -rf /var/log/pods/*
sudo rm -rf /var/log/containers/*

echo "[INFO] Preparation done. Please power off the VM and clone."

# ========== Important Notes ==========
# 1. After booting the cloned VM:
#    a. Change hostname
#    b. Set unique static IP (if needed)
#    c. Perform 'kubeadm join' to connect to the cluster
# ======================================
