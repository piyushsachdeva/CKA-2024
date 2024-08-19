# Day 34/40 - Step-By-Step Guide To Upgrade a Multi Node Kubernetes Cluster With Kubeadm

## Check out the video below for Day34 👇

[![Day 35/40 - Step-By-Step Guide To Upgrade a Multi Node Kubernetes Cluster With Kubeadm](https://img.youtube.com/vi/NtX75Ze47EU/sddefault.jpg)](https://youtu.be/NtX75Ze47EU)


### Kubernetes Release format

![image](https://github.com/user-attachments/assets/74a7de0a-4bc2-44a7-8c8d-084dde64073e)


>Note: ETCD and coredns have seperate version, rest of the components have the same version

### Upgrade process : 1 minor version at a time

![image](https://github.com/user-attachments/assets/0253dc11-0da8-411f-91cd-50a6a5bd1816)

### Upgrade steps

1) Upgrade master node
2) Ipgrade worker node

>Note: when master is down, mangement operation are down, pods continue to run

### Run on master

# Find the latest 1.31 version in the list.
# It should look like 1.31.x-*, where x is the latest patch.
```
sudo apt update
sudo apt-cache madison kubeadm
```
- Upgrade kubeadm using the below command
  
```
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.30.2-1.1’ && \
sudo apt-mark hold kubeadm
```

- `sudo kubeadm upgrade plan`
  This command will show you the version available to be upgraded
  


- Upgrade the system components using the below command
`sudo kubeadm upgrade apply vX.XX.0`

- k get nodes (shows kubelet version)

- Drain the node
```
kubectl drain <node-to-drain> --ignore-daemonsets
```

- Upgrade the kubelet and kubectl

```
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.30.2-1.1' kubectl='1.30.2-1.1' && \
sudo apt-mark hold kubelet kubectl
```

- Restart kubelet
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```
- Uncordon the node
```
kubectl uncordon <node-to-uncordon>
```


### Run on Worker 
Follow the same process as above or follow the below doc
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/



