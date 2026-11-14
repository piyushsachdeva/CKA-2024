## Task 13/40

In this exercise, you will explore manual scheduling, labels and selectors along with static pods

> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a local Kubernetes cluster by following [Day06 Video](https://youtu.be/RORhczcOrWs)

### Task details
- Create a pod and try to schedule it manually without the scheduler.
- Login to the control plane node and go to the directory of default static pod manifests and try to restart the control plane components
- Create 3 pods with the name as pod1, pod2 and pod3 based on the nginx image and use labels as env:test, env:dev and env:prod for each of these pods respectively.
- Then using the kubectl commands, filter the pods that have labels dev and prod.
