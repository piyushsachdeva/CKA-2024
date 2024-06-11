# Work in progress
# Certified Kubernetes Administrator(CKA) 2024
This is the GitHub repository to host all the notes, diagrams, assignments, and resources from the CKA course published on YouTube.

### Day 1: Docker Fundamentals
**Status**: Yet to be published

- What is Docker?
- How is it different from Virtual Machines
-  Docker Architecture
-  Docker flow
-  Docker commands
    
### Day 2 Video: Dockerize an application
**Status**: Yet to be published
- What is Dockerfile, and how do you write it?
- docker pull , push, tag etc

## Day3 Video: Docker Multi-Stage Builds
- How to write dockerfile for multistage build
- Benefits of multi-stage builds
- Other docker best practises

## Day 4 Video: Why do We need Kubernetes?

## Day 5 Video: Kubernetes Architecture
- Control plane VS Worker Nodes
- Overview of control plane components

## Day 6 Video: Install Kubernetes Cluster locally

- Install Kind cluster locally
- How to access the cluster

## Day7 Video: Pods in Kubernetes

- What are pods in Kubernetes?
- Containers VS Pods
- Imperative VS Declarative way for creating Kubernetes resources
- Create a sample pod using the imperative way
- Create a sample pod using the declarative way
- Inspect the pods

## Day8 Video: Replicasets and Deployments in Kubernetes:
- Replication Controller
- ReplicaSet
- Deployments
- How to perform Rolling updates/rollback
- Scale the deployment

## Day9 Video: Services in Kubernetes:

- What are services in Kubernetes, and why do we need them?
- Node port, ClusterIP, and LoadBalancer

## Day 10 Video: Namespaces:
- NameSpaces
- Services and namespaces
- Demo in-depth

## Day 11 Video: Multi-container Pods
- What are multi-container pods
- Multi-container pods pattern - sidecar/init etc
- Environment variables in Kubernetes
- Demo

## Day 12 Video: Daemonset, Cronjob, and job
- What are Daemonset, cronjobs and Jobs
- Cron fundamentals with examples
- Demo

## Day13 Video: Static Pods
- What are static pods
- Labels and selectors
- Manual Scheduling
- Demo

## Day14 Video: Taints and Tolerations
- What are taints and tolerations
- demo

## Day15 Video: Node Affinity

## Day16 Video: Resource Requests and Limits

## Day17 Video: Autoscaling in Kubernetes
- Horizontal VS Vertical Autoscaling
- HPA, VPA, Cluster autoscaling, NAP
- Metrics server
- Demo

## Day18 Video: Probes in Kubernetes
- Liveness VS Readiness Probes
- HTTP/TCP/Command-based health checks
- Demo

## Day19 Video: Config maps and Secrets
- concept and demo
  
## Day 20 Video: How SSL/TLS works
- Symmetric VS Asymmetric encryption
- SSL certificates and Certificate Authority

## Day 21 Video: TLS in Kubernetes
- How TLS works in Kubernetes
- Why we need TLS in Kubernetes
- Private key and public certificates
- Demo

## Day 22 Video: Authorization
- Authorization VS Authentication
- Authorization types, ABAC, RBAC, Node, Webhook
- Kubeconfig

## Day 23 Video: Role-based access control (RBAC)
- Role and role binding
- Generate and approve the certificate
- grant access to the user
- demo

## Day 24 Video: Cluster role and cluster role binding
- concept and demo

## Day 25 Video: Service Account
- What are service accounts, and why do we use them?
- Create a service account and grant access to it
- demo

## Day26 Video: Network Policies
- Network policy concept
- CNI installation
- enforce network policy by creating the object
  
## Below videos are in the recording process

- Docker storage
- CSI
- Storage Class
- Volumes and Persistent Volumes
- Volume modes, Access modes and reclaim policies for volumes

<details>
  <summary>6. Troubleshooting</summary>

- Monitor Cluster components, Evaluate cluster and node logging
- Understand how to monitor applications, metric server
- Manage container stdout & stderr logs
- Troubleshoot application failure
- Troubleshoot cluster component failure
- Network Troubleshooting
- Worker node failure - cordon and drain
</details>

<details>
  <summary>7. Installation</summary>

- Use Kubeadm to install a basic cluster
- Manage a highly-available Kubernetes cluster
- Provision underlying infrastructure to deploy a Kubernetes cluster
- Perform a version upgrade on a Kubernetes cluster using Kubeadm
- Implement etcd backup and restore
</details>

<details>
  <summary>8. Services and Networking</summary>

- Switching , Routing, DNS and Core-DNS
- Network Namespace
- Docker Networking
- CNI
- Understand host networking configuration on the cluster nodes
- Understand connectivity between Pods
- Know how to use Ingress controllers and Ingress resources
- Choose an appropriate container network interface plugin - CNI Weave
</details>

<details>
  <summary>9. Conclusion</summary>

- Exam Pattern
- Last minute preparation
- Tips and Tricks
</details>
