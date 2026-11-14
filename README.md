# Certified Kubernetes Administrator (CKA) 2026 (Latest curriculum)

This is the GitHub repository to host all the notes, diagrams, assignments, and resources from the CKA course published on YouTube.

Note: If you found the content helpful, consider giving the repository a star ⭐

> **Last verified: November 2026**, against Kubernetes v1.37, which is the version used in the CKA exam at that time. The videos of Day 1 to Day 40 were recorded in 2024 on Kubernetes 1.29 and 1.30. The concepts are the same, but where a command, a version or a tool has changed since then, the notes in this repository have the updated version along with a note about what is different from the video.

## 🔗 Join our community 👇


<a href="https://youtube.com/@techtutorialswithpiyush"><img src="https://www.freeiconspng.com/thumbs/youtube-icon/video-youtube-icon--14.png" height="60px"></img></a>
<a href="https://discord.com/invite/FMtJ2bVRUE"><img src="https://img.icons8.com/color/2x/discord--v2.png" height="60px"></img></a>
<a href="https://github.com/piyushsachdeva/"><img src="https://user-images.githubusercontent.com/91791257/235086411-9ec7aa5e-c095-44ce-b9e6-57b3bc3fead2.png" height="60px"></img></a>
<a href="https://twitter.com/thecloudopscomm"><img src="https://i.postimg.cc/pVqVTNJd/X-logo.png" height="60px"></img></a>
<a href="https://www.linkedin.com/company/thecloudopscomm/"><img src="https://img.icons8.com/fluency/2x/linkedin.png" height="60px"></img></a>
<a href="https://www.instagram.com/techtutorialswithpiyush/"><img src="https://user-images.githubusercontent.com/91791257/235086447-47658b7b-71fa-4baf-830a-3ba9b3a76a47.png" height="60px"></img></a>

## How to use this repository

- Every day has its own folder under [Resources](Resources). The `readme.md` file in the folder has the notes, the commands and the YAML used in the video, and the `task.md` file has the hands-on assignment for that day.
- Watch the video, read the notes, and then do the task on your own cluster. For Day 6 to Day 26, a local [kind](Resources/Day06) cluster is enough. From Day 27 onwards, you need the [kubeadm cluster](Resources/Day27) on virtual machines.
- The 40 days of the original series are followed by extra content (Day 43 onwards) that covers the topics added to the exam in the 2025 curriculum, such as Helm, Kustomize, Gateway API, CRDs and operators.
- The #40daysofkubernetes challenge that ran along with the series is over. The details and the winners are in [this file](%2340daysofkubernetes.md).

## CKA exam curriculum

| Domain | Weight | Covered in |
|---|---|---|
| Troubleshooting | 30% | Day 36 to 39 |
| Cluster Architecture, Installation & Configuration | 25% | Day 5, 21 to 25, 27, 34, 35, 43, 44, 49, 50, 53, 55 |
| Services & Networking | 20% | Day 9, 26, 30 to 33, 47, 48 |
| Workloads & Scheduling | 15% | Day 7, 8, 11 to 19, 46, 51 |
| Storage | 10% | Day 29, 45, 52 |

The exam details (format, environment, allowed documentation and tips) are in the [Day 41](Resources/Day41) notes. The official curriculum is published by the CNCF [here](https://github.com/cncf/curriculum).

## Course content

### Day 0: Intro to the series
[![Course Introduction](https://img.youtube.com/vi/6_gMoe7Ik8k/sddefault.jpg)](https://youtu.be/6_gMoe7Ik8k)
- Course Introduction
- Discord community server for assistance

### Day 1: Docker Fundamentals
📂 Notes, commands and tasks: [Day01](Resources/Day01)

- What is Docker?
- How is it different from Virtual Machines
- Docker Architecture
- Docker flow
- Docker commands

### Day 2: Dockerize an application
📂 Notes, commands and tasks: [Day02](Resources/Day02)

- What is a Dockerfile, and how do you write it?
- docker build, tag, push, pull, run, exec and logs

### Day 3: Docker Multi-Stage Builds
📂 Notes, commands and tasks: [Day03](Resources/Day03)

- How to write a Dockerfile for a multi-stage build
- Benefits of multi-stage builds
- Other Docker best practices

### Day 4: Why do We need Kubernetes?
📂 Notes, commands and tasks: [Day04](Resources/Day04)

- Challenges of using standalone containers
- How Kubernetes solves those challenges

### Day 5: Kubernetes Architecture
📂 Notes, commands and tasks: [Day05](Resources/Day05)

- Control plane VS Worker Nodes
- Overview of control plane components

### Day 6: Install Kubernetes Cluster locally
📂 Notes, commands and tasks: [Day06](Resources/Day06)

- Install a Kind cluster locally
- How to access the cluster

### Day 7: Pods in Kubernetes
📂 Notes, commands and tasks: [Day07](Resources/Day07)

- What are pods in Kubernetes?
- Containers VS Pods
- Imperative VS Declarative way for creating Kubernetes resources
- Create a sample pod using the imperative way
- Create a sample pod using the declarative way
- Inspect the pods

### Day 8: Replicasets and Deployments in Kubernetes
📂 Notes, commands and tasks: [Day08](Resources/Day08)

- Replication Controller
- ReplicaSet
- Deployments
- How to perform Rolling updates/rollback
- Scale the deployment

### Day 9: Services in Kubernetes
📂 Notes, commands and tasks: [Day09](Resources/Day09)

- What are services in Kubernetes, and why do we need them?
- ClusterIP, NodePort, LoadBalancer and ExternalName

### Day 10: Namespaces
📂 Notes, commands and tasks: [Day10](Resources/Day10)

- Namespaces
- Services and namespaces

### Day 11: Multi-container Pods
📂 Notes, commands and tasks: [Day11](Resources/Day11)

- What are multi-container pods
- Multi-container pod patterns - sidecar, init etc
- Environment variables in Kubernetes

### Day 12: Daemonset, Cronjob, and job
📂 Notes, commands and tasks: [Day12](Resources/Day12)

- What are Daemonsets, Cronjobs and Jobs
- Cron fundamentals with examples

### Day 13: Static Pods
📂 Notes, commands and tasks: [Day13](Resources/Day13)

- What are static pods
- Labels and selectors
- Manual Scheduling

### Day 14: Taints and Tolerations
📂 Notes, commands and tasks: [Day14](Resources/Day14)

- Taints, tolerations and taint effects

### Day 15: Node Affinity
📂 Notes, commands and tasks: [Day15](Resources/Day15)

- Node selector VS node affinity
- Required and preferred rules

### Day 16: Resource Requests and Limits
📂 Notes, commands and tasks: [Day16](Resources/Day16)

- Requests VS limits
- What happens when a container crosses its limit
- Metrics server

### Day 17: Autoscaling in Kubernetes
📂 Notes, commands and tasks: [Day17](Resources/Day17)

- Horizontal VS Vertical Autoscaling
- HPA, VPA, Cluster autoscaling, NAP
- Metrics server

### Day 18: Probes in Kubernetes
📂 Notes, commands and tasks: [Day18](Resources/Day18)

- Liveness VS Readiness VS Startup Probes
- HTTP/TCP/Command-based health checks

### Day 19: Config maps and Secrets
📂 Notes, commands and tasks: [Day19](Resources/Day19)

- Concept and demo

### Day 20: How SSL/TLS works
📂 Notes, commands and tasks: [Day20](Resources/Day20)

- Symmetric VS Asymmetric encryption
- SSL certificates and Certificate Authority

### Day 21: TLS in Kubernetes
📂 Notes, commands and tasks: [Day21](Resources/Day21)

- How TLS works in Kubernetes
- Why we need TLS in Kubernetes
- Private key and public certificates
- CertificateSigningRequest

### Day 22: Authorization in Kubernetes
📂 Notes, commands and tasks: [Day22](Resources/Day22)

- Authorization VS Authentication
- Authorization types, ABAC, RBAC, Node, Webhook
- Kubeconfig

### Day 23: Role-based access control (RBAC)
📂 Notes, commands and tasks: [Day23](Resources/Day23)

- Role and role binding
- Generate and approve the certificate
- Grant access to the user

### Day 24: Cluster role and cluster role binding
📂 Notes, commands and tasks: [Day24](Resources/Day24)

- Concept and demo

### Day 25: Service Account
📂 Notes, commands and tasks: [Day25](Resources/Day25)

- What are service accounts, and why do we use them?
- Create a service account and grant access to it

### Day 26: Network Policies
📂 Notes, commands and tasks: [Day26](Resources/Day26)

- Network policy concept
- CNI installation
- Enforce a network policy by creating the object

### Day 27: Use Kubeadm to install a Kubernetes cluster
📂 Notes, commands and tasks: [Day27](Resources/Day27)

- Provision underlying infrastructure to deploy a Kubernetes cluster
- Set up the control plane (master) node
- Set up multiple worker nodes and join them to the cluster

### Day 28: Docker storage fundamentals
📂 Notes, commands and tasks: [Day28](Resources/Day28)

- Why do we need storage in docker containers
- Persistent docker storage

### Day 29: Storage in Kubernetes
📂 Notes, commands and tasks: [Day29](Resources/Day29)

- How storage works in Kubernetes
- hostPath volumes in Kubernetes
- Persistent volumes and Persistent volume claims
- Volume modes, Access modes, and reclaim policies for volumes
- Storage classes and provisioners

### Day 30: How does DNS work?
📂 Notes, commands and tasks: [Day30](Resources/Day30)

- What happens when you type a website address in your browser
- Different components involved in DNS
- End-to-end flow
- Important files and resources

### Day 31: DNS in Kubernetes
📂 Notes, commands and tasks: [Day31](Resources/Day31)

- How DNS works in Kubernetes
- CoreDNS

### Day 32: Kubernetes Networking
📂 Notes, commands and tasks: [Day32](Resources/Day32)

- CNI, network add-on
- containerd VS runc, container runtime

### Day 33: Ingress controller and Ingress resources
📂 Notes, commands and tasks: [Day33](Resources/Day33)

- Ingress, Ingress controller and IngressClass
- Expose an application with an Ingress

### Day 34: Perform a version upgrade on a Kubernetes cluster using Kubeadm
📂 Notes, commands and tasks: [Day34](Resources/Day34)

- Upgrade the control plane node
- Upgrade the worker nodes

### Day 35: Implement etcd backup and restore
📂 Notes, commands and tasks: [Day35](Resources/Day35)

- Take an etcd snapshot with etcdctl
- Restore it with etcdutl

### Day 36: Monitoring, Logging and Alerting
📂 Notes, commands and tasks: [Day36](Resources/Day36)

- Monitor cluster components, evaluate cluster and node logging
- Understand how to monitor applications, metrics server
- Manage container stdout & stderr logs

### Day 37: Troubleshoot application failure
📂 Notes, commands and tasks: [Day37](Resources/Day37)

- Pod, Service and configuration issues

### Day 38: Troubleshoot cluster component failure
📂 Notes, commands and tasks: [Day38](Resources/Day38)

- API server, scheduler, controller manager and etcd issues

### Day 39: Troubleshoot worker node failure and networking
📂 Notes, commands and tasks: [Day39](Resources/Day39)

- Worker node failure
- cordon, uncordon and drain (maintenance)
- Network troubleshooting

### Day 40: JSONPath, advanced kubectl commands
📂 Notes, commands and tasks: [Day40](Resources/Day40)

- JSON for beginners
- JSON v/s YAML
- JSONPath basics
- Multiple JSONPath queries to fetch details

### Day 41: Mission CKA
📂 Notes, commands and tasks: [Day41](Resources/Day41)

- Exam pattern
- Pre-requisites
- Last-minute preparation
- Tips and Tricks
- Sample questions

### Day 42: Realtime project: Host your own container registry on Kubernetes
📂 Notes, commands and tasks: [Day42](Resources/Day42)

- This project includes multiple Kubernetes topics with real-time implementation.

### Day 43: Helm
📂 Notes, commands and tasks: [Helm](Resources/Helm)

- Charts, repositories and releases
- Install, upgrade, roll back and uninstall

### Day 44: Kustomize
📂 Notes, commands and tasks: [Kustomize](Resources/Kustomize)

- kustomization.yaml
- Bases, overlays and patches

### Day 45: StatefulSets
📂 Notes, commands and tasks: [Day45-StatefulSet](Resources/Day45-StatefulSet)

- Headless service, volumeClaimTemplates, ordered scaling

### Day 46: Priority class and preemption
📂 Notes, commands and tasks: [Day46-PriorityClass](Resources/Day46-PriorityClass)

- PriorityClass and how the scheduler preempts pods

### Day 47: Gateway API
📂 Notes, commands and tasks: [day47-GatewayAPI](Resources/day47-GatewayAPI)

- GatewayClass, Gateway and HTTPRoute

### Day 48: Migrate from Ingress to Gateway API
📂 Notes, commands and tasks: [Day48-Migrate-Ingress-to-Gateway](Resources/Day48-Migrate-Ingress-to-Gateway)

- Convert an existing Ingress with TLS into a Gateway and an HTTPRoute

### Day 49: Custom Resources and CRDs
📂 Notes, commands and tasks: [Day49-CustomResources](Resources/Day49-CustomResources)

- Create a CRD and a custom resource
- Work with the CRDs of installed tools

### Day 50: Operators
📂 Notes, commands and tasks: [Day-50-Operators](Resources/Day-50-Operators)

- Operator pattern and reconciliation
- Install an operator with OLM

### Day 51: Admission controllers
📂 Notes, commands and tasks: [Day51-AdmissionControllers](Resources/Day51-AdmissionControllers)

- Built-in admission controllers, ResourceQuota and LimitRange
- Admission webhooks and policies

### Day 52: StorageClass and dynamic provisioning
📂 Notes, commands and tasks: [Day52-StorageClass-DynamicProvisioning](Resources/Day52-StorageClass-DynamicProvisioning)

- Static VS dynamic provisioning
- Default StorageClass, reclaim policy and volume binding mode

### Day 53: CRI-Dockerd setup
📂 Notes, commands and tasks: [Day53-DockerD-Setup](Resources/Day53-DockerD-Setup)

- Install and configure cri-dockerd as a container runtime

### Day 54: Pod security
📂 Notes, commands and tasks: [Day54-PodSecurity](Resources/Day54-PodSecurity)

- Linux capabilities and security context
- Pod Security Standards

### Day 55: Highly available control plane
📂 Notes, commands and tasks: [Day55-HA-Controlplane.md](Resources/Day55-HA-Controlplane.md)

- HAProxy load balancer
- Multiple control plane nodes with stacked etcd

## Frequently asked questions:

### 1) I cannot afford the CKA exam, it's too expensive. Should I still follow along?

The content of this playlist is based on the exam curriculum because it provides a well-organized learning path. You don't have to worry about the roadmap; you can focus on learning. Even if you are not taking the exam now, you are still gaining the hands-on knowledge that a Kubernetes administrator should have; that's good enough!

### 2) What are the prerequisites for this course?

The only prerequisite is a basic understanding of Linux; all the other prerequisites, such as Docker, are already covered in this series. Yes, it is absolutely free for anyone to join and follow along.

### 3) Which Cloud provider are we using for the demo?

We will not be using any managed Kubernetes service of a cloud provider, as the focus is on Kubernetes itself. With a managed service, the cloud provider manages the control plane, which limits the learning. We will use a local Kubernetes installation on a Kind cluster and a Kubeadm installation on virtual machines. Those virtual machines can be on your laptop or on any cloud.

### 4) Are we doing any real-time projects in this series?

Yes, there is a real-time project at the end of this series ([Day 42](Resources/Day42)). We cannot do real-time full-fledged projects in Kubernetes without completing all the essential topics. That is why the project is at the end, with hands-on tasks in almost every video before it.

### 5) Is the series complete?

Yes. All the videos of the 40 days are published, and you can follow them at your own pace. The content from Day 43 onwards was added later to cover the topics of the 2025 exam curriculum.

### 6) What if we are stuck somewhere and need assistance?

You can comment on the video by providing complete details about the issue/query, or you can open a new thread in the Discord channel `help-cka-2024`, and someone will help you. If you find a mistake in these notes, please open an issue or a pull request in this repository.
