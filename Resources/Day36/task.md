## Task 36/40

In this exercise, you will explore how monitoring and logging works in Kubernetes

> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a Kubernetes cluster using `kubeadm` by following Day 27 video.

### Task details
1. Install the Metrics Server using the manifest in the Day16 folder, and read this [doc](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/) to understand how it works (in the exam, it is already installed)
2. Perform the steps shown in the video tutorial
3. Find the pod that uses the most CPU in the `kube-system` namespace and write its name to a file
4. Read the kubelet logs on a worker node using `journalctl`
5. Read the logs of the kube-apiserver container using `crictl`, without using `kubectl`
