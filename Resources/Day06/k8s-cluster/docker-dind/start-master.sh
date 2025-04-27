#!/bin/bash

containerd &

sleep 5

kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Swap,ImagePull

mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config

# Generate join command
kubeadm token create --print-join-command > /shared/join-command.sh

# Install flannel CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

tail -f /dev/null

