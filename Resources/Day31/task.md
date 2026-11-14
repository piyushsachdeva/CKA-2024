## Task 31/40

In this exercise, you will explore coreDNS in Kubernetes.

> [!NOTE]
> Make sure you have a Kubernetes cluster created setup on virtual machines, you can follow [this video](https://youtu.be/WcdMC3Lj4tU) as a pre-requisites
> If you don't know the DNS concepts, make sure to watch the Day 30 video before this one.

### Task details
1. Document your learning and understanding of coreDNS from the video.
2. Find the IP address of the cluster DNS service and confirm that the same IP is in `/etc/resolv.conf` of a pod.
3. Create a deployment and a service in a new namespace and resolve the service from a pod in the `default` namespace using its short name, `<service>.<namespace>` and the FQDN. Note which of these work and why.
4. Scale the coredns deployment to 0, try the lookup again, and then scale it back to 2.
