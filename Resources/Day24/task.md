## Task 24/40

In this exercise, you will work with ClusterRole and ClusterRoleBinding in Kubernetes

### Task details
1. Try to run the commands and steps as per the video and document your learning
2. Create a ClusterRole that can get, list and watch nodes, and bind it to your user with a ClusterRoleBinding. Verify with `kubectl auth can-i`
3. Create a ClusterRole that can read secrets, and bind it to your user with a RoleBinding in the `default` namespace only. Verify that the user can read secrets in `default` but not in `kube-system`
