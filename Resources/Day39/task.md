## Task 39/40

In this exercise, you will explore how to troubleshoot worker node failures in Kubernetes from CKA exam perspective
> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a Kubernetes cluster using `kubeadm` by following Day 27 video.

### Task details
1. Login to your cluster on worker node1 and clone this repo.
2. cd into the cloned directory inside `CKA-2024/Resources/Day39` folder
3. Execute the below .sh file which introduces issues in your cluster (Do not open the file)
`chmod +x problem1.sh; ./problem1.sh`
4. Check your cluster health again and fix the nodes.
5. Once, your nodes are in ready status, clone the repo on worker node2
6. Execute the below .sh file which introduces issues in your cluster (Do not open the file)
`chmod +x problem2.sh; ./problem2.sh`
7. Check your cluster health again and fix the nodes.
