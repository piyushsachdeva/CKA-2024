
# Certified Kubernetes Administrator(CKA) 2024
This is the GitHub repository to host all the notes, diagrams, assignments, and resources from the CKA course published on YouTube.

Note: Expand each of the section to view the details.
<details>
  <summary>1. Cluster Architecture and core concepts</summary>

  
- **Day1 Video**: Docker Fundamentals
    -  What is Docker?
    -  How is it different from Virtual Machines
    -  Docker Architecture
    -  Docker flow
    -  Docker commands
- Dockerize an application, pull , push, tag etc
- Kubernetes Architecture
- Docker Vs ContainerD
- kubectl cli 
- ETCD
- KubeAPIServer
- Kube Controller Manager
- Kube Schedular
- Kubelet
- Kube Proxy
</details>

<details>
  <summary>2. Workloads</summary>

- Services in Kubernetes: Nodeport, ClusterIP,LoadBalancer
- NameSpaces
- Commands and Arguments
- Config maps and environment variables
- Multi container pod ,init/sidecar containers
- Pods and Containers - Deploy a sample application, Imperative commands vs declarative commands - kubectl cli
- Replica Sets and Deployments: how to perform rolling update and rollbacks, scale the deployment
- Jobs, cronjobs
- Daemonsets
</details>

<details>
  <summary>3. Scheduling for High Availability</summary>

- Labels and Selectors , Node selectors
- Taints and Tolerations
- Node Affinity and Node Anti-Affinity
- Resource requirements and Limits
- Static Pods: scheduling without the schedular.
- Multiple Schedulars
- Kubernetes autoscaling: HPA, VPA, Cluster Autoscaling etc
- Understand the primitives used to create robust, self-healing, application deployments
- Awareness of manifest management and common templating tools: helm chart
</details>

<details>
  <summary>4. Security</summary>

- TLS and Certificates
- Kubeconfig , creating kubeconfig
- Security context
- Secrets and secret encryption: mounting secret on a pod, best practices
- RBACs , Authorization and Authentication
- Cluster roles and role bindings
- Service Account
- Image Security and context
- Network Policies
</details>

<details>
  <summary>5. Storage</summary>

- Docker storage
- CSI
- Storage Class
- Volumes and Persistent Volumes
- Volume modes, Access modes and reclaim polocies for volumes
- Understand persistent volume claims primitive
- Know how to configure applications with persistent storage
</details>

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
