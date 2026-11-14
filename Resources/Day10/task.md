## Task 10/40


In this exercise, you will explore namespaces in depth by creating multiple Kubernetes resources.

> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a local Kubernetes cluster by following [Day06 Video](https://youtu.be/RORhczcOrWs)

### Task details
- Create two namespaces and name them ns1 and ns2
- Create a deployment with a single replica in each of these namespaces with the image as nginx and name as deploy-ns1 and deploy-ns2, respectively
- Get the IP address of each of the pods (Remember the kubectl command for that?)
- Exec into the pod of deploy-ns1 and try to curl the IP address of the pod running on deploy-ns2
- Your pod-to-pod connection should work, and you should be able to get a successful response back.
- Now scale both of your deployments from 1 to 3 replicas.
- Create two services to expose both of your deployments and name them svc-ns1 and svc-ns2
- exec into each pod and try to curl the IP address of the service running on the other namespace.
- This curl should work.
- Now try curling the service in the other namespace by its short name (for example `svc-ns2` from a pod in ns1) instead of the IP. You will notice that you are getting an error and cannot resolve the host, because a short name is only resolved inside the pod's own namespace.
- Now use the FQDN of the service (`svc-ns2.ns2.svc.cluster.local`) and try to curl again, this should work.
- In the end, delete both the namespaces, which should delete the services and deployments underneath them.
