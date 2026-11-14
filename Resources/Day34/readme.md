# Day 34/40 - Step-By-Step Guide To Upgrade a Multi Node Kubernetes Cluster With Kubeadm

## Check out the video below for Day34 👇

[![Day 35/40 - Step-By-Step Guide To Upgrade a Multi Node Kubernetes Cluster With Kubeadm](https://img.youtube.com/vi/NtX75Ze47EU/sddefault.jpg)](https://youtu.be/NtX75Ze47EU)

> Note: The video upgrades a cluster from 1.29 to 1.30. The commands below have been updated to upgrade from **1.36 to 1.37**, which matches the cluster that you built with the updated [Day27](../Day27) steps. The process is the same for any version. Only the version numbers change.

### Kubernetes Release format

![image](https://github.com/user-attachments/assets/74a7de0a-4bc2-44a7-8c8d-084dde64073e)


>Note: etcd and CoreDNS have their own version numbers. The rest of the components have the same version as Kubernetes.

### Upgrade process : 1 minor version at a time

![image](https://github.com/user-attachments/assets/0253dc11-0da8-411f-91cd-50a6a5bd1816)

- You cannot skip a minor version. To go from 1.35 to 1.37, you first upgrade to 1.36 and then to 1.37.
- Always upgrade `kubeadm` first, then the control plane, then `kubelet` and `kubectl`.
- The kubelet on a node must never be newer than the API server.

### Upgrade steps

1) Upgrade the master (control plane) node
2) Upgrade the worker nodes, one at a time

>Note: While the master node is being upgraded, management operations are not available (you cannot run kubectl, and failed pods are not replaced). The pods that are already running on the worker nodes continue to run.

### Run on master

- Each Kubernetes minor version has its own apt repository. Point the repository to the new minor version first, otherwise apt cannot see the 1.37 packages. This step is easy to miss.

```bash
sudo sed -i 's/v1.36/v1.37/g' /etc/apt/sources.list.d/kubernetes.list
cat /etc/apt/sources.list.d/kubernetes.list
```

- Find the latest 1.37 patch version in the list. It should look like `1.37.x-*`, where x is the latest patch.

```bash
sudo apt update
sudo apt-cache madison kubeadm
```

- Upgrade kubeadm using the below command (replace `1.37.1-1.1` with the version that you found above)

```bash
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.37.1-1.1' && \
sudo apt-mark hold kubeadm
```

- Verify that kubeadm has the new version

```bash
kubeadm version
```

- Check the upgrade plan. This command checks whether the cluster can be upgraded and shows the versions that you can upgrade to.

```bash
sudo kubeadm upgrade plan
```

- Upgrade the control plane components using the below command

```bash
sudo kubeadm upgrade apply v1.37.1
```

- `kubectl get nodes` still shows the old version at this point, because this column shows the kubelet version and we have not upgraded the kubelet yet.

- Drain the node

```bash
kubectl drain <node-to-drain> --ignore-daemonsets
```

- Upgrade the kubelet and kubectl

```bash
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.37.1-1.1' kubectl='1.37.1-1.1' && \
sudo apt-mark hold kubelet kubectl
```

- Restart kubelet
```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```
- Uncordon the node
```bash
kubectl uncordon <node-to-uncordon>
```


### Run on Worker

The steps on a worker node are almost the same. The two differences are that you run `kubeadm upgrade node` in place of `kubeadm upgrade plan` and `kubeadm upgrade apply`, and that the `kubectl drain` and `kubectl uncordon` commands are run from the master node, because the worker does not have a kubeconfig.

```bash
# on the worker node
sudo sed -i 's/v1.36/v1.37/g' /etc/apt/sources.list.d/kubernetes.list
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.37.1-1.1' && \
sudo apt-mark hold kubeadm
sudo kubeadm upgrade node

# on the master node
kubectl drain <worker-node> --ignore-daemonsets

# on the worker node
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.37.1-1.1' kubectl='1.37.1-1.1' && \
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# on the master node
kubectl uncordon <worker-node>
```

Repeat for the next worker node. You can also follow the below doc
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/

### Verify

```bash
kubectl get nodes
kubectl get pods -A
```

All the nodes should be `Ready` and show the new version.

>Note: If `kubectl drain` fails because of pods that use `emptyDir` volumes, add `--delete-emptydir-data`. If it fails because of pods that are not managed by a controller, add `--force`. Those pods are deleted and will not come back on their own.

>Note: In the exam, you are usually asked to upgrade only the control plane node, or only one node, and to a specific patch version. Read the task carefully and upgrade only what is asked.
