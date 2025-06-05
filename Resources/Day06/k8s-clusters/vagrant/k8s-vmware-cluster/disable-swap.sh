#!/bin/bash

echo "Disabling swap..."

# Turn off swap immediately
sudo swapoff -a

# Comment out any swap entry in /etc/fstab to prevent it from re-enabling
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab

# Restart kubelet so Kubernetes doesn't complain
sudo systemctl restart kubelet

echo "Swap disabled and kubelet restarted."