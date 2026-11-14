# Day 32/40 - Kubernetes Networking Explained | Container Network Interface (CNI) 

## Check out the video below for Day32 👇

[![Day 32/40 - Kubernetes Networking Explained | Container Network Interface (CNI)](https://img.youtube.com/vi/EkAzMGldC5M/sddefault.jpg)](https://youtu.be/EkAzMGldC5M)


### Find more useful resource here:
https://github.com/saiyam1814/kube-networking

### Key points from the video

- **CRI (Container Runtime Interface)** is the API that the kubelet uses to talk to the container runtime. containerd and CRI-O implement it. Docker Engine does not, so it needs the `cri-dockerd` adapter (see the [Day53](../Day53-DockerD-Setup) folder).
- **containerd** is the high-level runtime. It pulls images, manages storage and networking for containers, and calls **runc**, the low-level runtime that actually creates the container process using Linux namespaces and cgroups.
- **CNI (Container Network Interface)** is the standard that the container runtime uses to set up pod networking. The CNI plugin gives every pod an IP address and makes sure pods on different nodes can reach each other.
- **CSI (Container Storage Interface)** is the same idea for storage. A CSI driver lets Kubernetes create and attach volumes from a storage system.
- The Kubernetes network model has a few simple rules: every pod gets its own IP address, all pods can reach each other without NAT, and all the containers in a pod share one network namespace, so they talk to each other over `localhost`.
- Kubernetes does not ship with a CNI plugin. Until you install one (Calico, Cilium, Flannel and so on), the nodes stay in `NotReady` and the CoreDNS pods stay in `Pending`.

### Where to look on a node

```bash
ls /opt/cni/bin            # CNI plugin binaries
ls /etc/cni/net.d          # CNI configuration that the runtime reads
ip addr                    # interfaces on the node, including the ones created by the CNI plugin
ip route                   # routes to the pod networks of the other nodes
ip netns list              # network namespaces of the pods

# crictl talks to the container runtime directly. Use it when kubectl is not working
sudo crictl ps -a
sudo crictl pods
sudo crictl images
sudo crictl logs <container-id>
sudo crictl inspect <container-id>
```
