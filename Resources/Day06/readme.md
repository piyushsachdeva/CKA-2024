### Please follow task.md for the Day6 assignment

**Documentation followed in this video:**
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- Kind cluster [docs](https://kind.sigs.k8s.io/docs/user/quick-start/)
- kind example config [yaml](https://raw.githubusercontent.com/kubernetes-sigs/kind/main/site/content/docs/user/kind-example-config.yaml)
- kind [release notes](https://github.com/kubernetes-sigs/kind/releases), which list the node image for every supported Kubernetes version

**Commands used in the video**

```bash
# single node cluster with the default Kubernetes version of your kind release
kind create cluster --name cka-cluster1

# single node cluster with a specific Kubernetes version
kind create cluster --name cka-cluster1 --image kindest/node:v1.36.4

# multi-node cluster from a config file
kind create cluster --name cka-cluster2 --config config.yaml --image kindest/node:v1.37.0

# list clusters and switch between them
kind get clusters
kubectl config get-contexts
kubectl config use-context kind-cka-cluster2
kubectl get nodes

# delete a cluster
kind delete cluster --name cka-cluster1
```

Sample `config.yaml` for 1 control plane node and 3 worker nodes:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

> Note: The video uses Kubernetes 1.29 and 1.30 node images. Those versions are end of life. The CKA exam runs Kubernetes v1.37 as of November 2026, so the commands above use the 1.36 and 1.37 images that ship with kind v0.33.0. Check the kind release notes for the image tags that match your kind version.

**Only the below sites are allowed to be referred to in the CKA exam**
- https://kubernetes.io/docs
- https://kubernetes.io/blog/
- https://helm.sh/docs
- https://gateway-api.sigs.k8s.io
- Kubernetes cheat sheet (part of the docs): https://kubernetes.io/docs/reference/kubectl/quick-reference/

The Linux Foundation maintains the official list [here](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed). Check it before your exam because it changes from time to time.
