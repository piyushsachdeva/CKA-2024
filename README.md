# Certified Kubernetes Administrator(CKA) 2024 

This is the GitHub repository to host all the notes, diagrams, assignments, and resources from the CKA course published on YouTube.

Note: If you found the content helpful, consider giving the repository a star ⭐

**Checkout this [file](https://github.com/piyushsachdeva/CKA-2024/blob/main/%2340daysofkubernetes.md) for the #40daysofkubernetes challenge details**

### Day0: Intro to the series
[![Course Introduction](https://img.youtube.com/vi/6_gMoe7Ik8k/sddefault.jpg)](https://youtu.be/6_gMoe7Ik8k)
- Course Introduction
- Discord community server for assistance
- Live QnA sessions every weekend
- #40daysofkubernetes challenge

### Day 1: Docker Fundamentals
**Status**: Video is live, check out 👉 [Day1](https://github.com/piyushsachdeva/CKA-2024/tree/main/Resources/Day01) 👈 folder for notes and useful links ✅

- What is Docker?
- How is it different from Virtual Machines
-  Docker Architecture
-  Docker flow
-  Docker commands
    
### Day 2 Video: Dockerize an application
**Status**: Video is live, check out 👉 [Day2](https://github.com/piyushsachdeva/CKA-2024/tree/main/Resources/Day02) 👈 folder for notes and useful links ✅
- What is Dockerfile, and how do you write it?
- docker pull , push, tag etc

## Day3 Video: Docker Multi-Stage Builds
**Status**: Video is live, check out 👉 [Day3](https://github.com/piyushsachdeva/CKA-2024/tree/main/Resources/Day03) 👈 folder for notes and useful links ✅
- How to write a dockerfile for multistage build
- Benefits of multi-stage builds
- Other docker best practices

## Day 4 Video: Why do We need Kubernetes?
**Status**:  Video Live Date: 20th June

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


## Day 11 Video: Multi-container Pods
- What are multi-container pods
- Multi-container pods pattern - sidecar/init etc
- Environment variables in Kubernetes


## Day 12 Video: Daemonset, Cronjob, and job
- What are Daemonset, cronjobs and Jobs
- Cron fundamentals with examples


## Day13 Video: Static Pods
- What are static pods
- Labels and selectors
- Manual Scheduling


## Day14 Video: Taints and Tolerations
- What are taints and tolerations


## Day15 Video: Node Affinity

## Day16 Video: Resource Requests and Limits

## Day17 Video: Autoscaling in Kubernetes
- Horizontal VS Vertical Autoscaling
- HPA, VPA, Cluster autoscaling, NAP
- Metrics server


## Day18 Video: Probes in Kubernetes
- Liveness VS Readiness Probes
- HTTP/TCP/Command-based health checks


## Day19 Video: Config maps and Secrets
- concept and demo
  
## Day 20 Video: How SSL/TLS works
- Symmetric VS Asymmetric encryption
- SSL certificates and Certificate Authority

## Day 21 Video: TLS in Kubernetes
- How TLS works in Kubernetes
- Why we need TLS in Kubernetes
- Private key and public certificates


## Day 22 Video: Authorization
- Authorization VS Authentication
- Authorization types, ABAC, RBAC, Node, Webhook
- Kubeconfig

## Day 23 Video: Role-based access control (RBAC)
- Role and role binding
- Generate and approve the certificate
- grant access to the user


## Day 24 Video: Cluster role and cluster role binding
- concept and demo

## Day 25 Video: Service Account
- What are service accounts, and why do we use them?
- Create a service account and grant access to it


## Day26 Video: Network Policies
- Network policy concept
- CNI installation
- enforce network policy by creating the object
  
## Day27 Video: Use Kubeadm to install a Kubernetes cluster
- Provision underlying infrastructure to deploy a Kubernetes cluster
- Setup Master Node to deploy Kubernetes components
- Setup multiple worker nodes and join the master node

## Day28 Video: Docker storage fundamentals
- Why do we need storage in docker containers
- persistent docker storage

## Day29 Video: Storage in Kubernetes
- How storage works in Kubernetes
- hostpath volumes in Kubernetes
- Persistent volumes and Persistent volume claims
- Volume modes, Access modes, and reclaim policies for volumes
- Storage classes and provisions

## Day30 Video: How does DNS work?
- What happens when you type a website address in your browser
- different components involved in DNS
- End-to-end flow
- Important files and resources

## Day31 Video: Docker Networking
- How Networking works in a docker container

## Day32 Video: Kubernetes Networking
- CNI , Network Add-on
- Containerd vs runc , container runtime

## Day 33 Video: Ingress controller and Ingress resources

## Day 34 Video: Perform a version upgrade on a Kubernetes cluster using Kubeadm

## Day 35 Video: Implement etcd backup and restore

## Day 36 Video: Monitoring, Logging and Alerting
- Monitor Cluster components, Evaluate cluster and node logging
- Understand how to monitor applications, metric server
- Manage container stdout & stderr logs

## Day 36 Video: Troubleshoot application failure

## Day 37 Video: Troubleshoot cluster component failure

## Day 38 Video: Network Troubleshooting
 - Worker node failure
 - cordon, uncordon and drain (maintenance)

## Day 39 Video: Kubernetes Installation "the hard way"
- Installing Kubernetes manually using binaries

## Day 40 Video: Realtime project: Host your own container registry on Kubernetes
- This project will include multiple Kubernetes topics with real-time implementation.

## Bonus Video: Mission CKA

- Exam Pattern
- Last-minute preparation
- Tips and Tricks
