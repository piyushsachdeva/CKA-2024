## Task 6/40


1. **Task Details**
- Document your learnings from the video
- Following the [doc](https://kind.sigs.k8s.io/) install a single node kind cluster on your local machine with Kubernetes version 1.36
- Delete the cluster created in the above step
- Following the same [doc](https://kind.sigs.k8s.io/) install a multi-node kind cluster on your local machine using the below details:
    - **Cluster Name** :- cka-cluster2
    - **Nodes**:- 1 Control plane and 3 worker nodes
    - **Kubernetes Version** :- 1.37
- Install the kubectl client on the machine using the [doc](https://kubernetes.io/docs/tasks/tools/#kubectl)
- Set the current context to the newly created cluster
- Run commands such as `kubectl get nodes` and ensure you have all the nodes ready
- These nodes are nothing but containers as KIND means Kubernetes IN Docker, which creates containers and uses them as nodes.
- Run `docker ps` command to verify that all nodes are running as containers.

**Please remember to include references to the video in your blog and any documentation you follow.**
