# Day 42 - Realtime project: Host your own container registry on Kubernetes

## Below are the task details:

Your organization is evolving, and your CTO wants to streamline the build and deployment process.
As a DevOps engineer, you have been tasked to deploy a private container image registry on Kubernetes, in the
namespace called `40daysofkubernetes`. It should meet the following requirements:

**Cluster Provisioning:**
*  Provision a Kubernetes cluster with at least two worker nodes. The kubeadm cluster from Day 27 or a multi-node kind cluster is enough.
*  If you are using a managed cloud cluster, make it a regional cluster with the nodes spread across different availability zones.

**Registry Deployment:**
*  Create a Deployment named `registry-kube` with two replicas, and each replica should be scheduled on a separate node (hint: pod anti-affinity or topology spread constraints).
*  The pod runs a container named `registry-kube` with the image `registry:3`.
*  The registry should store images under `/var/lib/40daysofkubernetes`. The registry image stores its data under `/var/lib/registry` by default, so set the env variable `REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY` to the new path.

**Storage:**
*  Configure a Persistent Volume (PV) to store data for the application.
*  The PV should have at least 1Gi of storage space.
*  Ensure the data stored in the PV survives pod restarts.
*  Think about the access mode: two replicas on two different nodes that share one volume need `ReadWriteMany` storage (for example NFS). If your cluster only has `ReadWriteOnce` storage, note down what happens and how you would solve it.

**Container Configuration:**
*  The application container should expose itself on port 5000.
*  The kubelet should perform health checks on the `registry-kube` container and restart it if it doesn't respond on TCP port 5000 for 30 seconds. The kubelet should wait for 15 seconds before performing its first health check.
*  The container should request 1Gi memory, and the limit should be 2Gi.

**Init Container:**
*  Implement an init container within the `registry-kube` deployment to ensure the presence of the data directory required by the registry.
*  The init container should use an Alpine-based image and create the data directory `/var/lib/40daysofkubernetes` if it doesn't exist.

**Service Exposure:**
*  Create a Kubernetes LoadBalancer service to expose the application externally. On a cluster without a cloud load balancer, use a NodePort service.
*  The service should map an external port to port 5000 on the pods.

**Network Policies:**
*  Implement Network Policies to restrict incoming and outgoing network traffic for the registry pods.
*  Allow only the traffic that the registry needs (incoming on port 5000).

**Secrets and ConfigMap:**
*  Store sensitive information in Kubernetes Secrets, such as the htpasswd file with the authentication credentials for the registry.
*  Utilize a ConfigMap to manage configuration settings for the registry deployment.

**Backup and Recovery:**
*  Define a backup strategy for the data stored in the Persistent Volume.
*  Explore options for restoring the registry in case of data loss or pod failures.

**Verify:**
*  Tag a small image, push it to your registry and pull it back.
*  Delete one registry pod and confirm that the image is still available.
