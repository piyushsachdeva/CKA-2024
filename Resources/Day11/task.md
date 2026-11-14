## Task 11/40


In this exercise, you will explore environment variables and multi-container pods in Kubernetes.

> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a local Kubernetes cluster by following [Day06 Video](https://youtu.be/RORhczcOrWs)

### Task details
- Create a multi-container pod as per the demo shown in the video.
- Create the two services that the init containers are waiting for and confirm that the pod moves to `Running`.
- Create a pod with a sidecar container (an init container with `restartPolicy: Always`) that shares an `emptyDir` volume with the main container, as shown in the readme.
