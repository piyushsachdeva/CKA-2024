## Task 15/40

In this exercise, you will explore Node Affinity in Kubernetes
> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a local Kubernetes cluster by following [Day06 Video](https://youtu.be/RORhczcOrWs)

### Task details
- create a pod with nginx as the image and add the nodeAffinity with property requiredDuringSchedulingIgnoredDuringExecution and condition disktype = ssd
- check the status of the pod and see why it is not scheduled
- add the label to your worker01 node as disktype=ssd and then check the status of the pod
- It should be scheduled on worker node 1
- create a new pod with redis as the image and add the nodeAffinity with property requiredDuringSchedulingIgnoredDuringExecution and condition disktype without any value (operator `Exists`)
- add the label to worker02 node with disktype and no value
- ensure that the redis pod is scheduled on worker02 node
