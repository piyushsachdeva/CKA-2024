# Why Kubernetes Is Used - Kubernetes Simply Explained
## 40 days of K8s - CKA challenge (04/40)

@piyushsachdeva

## [Day 4/40 - Why Kubernetes Is Used - Kubernetes Simply Explained - CKA Full Course 2025](https://www.youtube.com/watch?v=ajetvJmBvFo&ab_channel=TechTutorialswithPiyush)

this post summerise what is an orchestrator and why Kubernetes (__K8s__)  

<hr/>

# 1. what is an Orchestrator , why do we need k8s to 

after we learnt about Docker - we understand that we can create a containerized environment to work as production, as well as testing. 

this system can be scaled and maintained automatically - if we just had an orchestraiting system to manage it. 


A  __container orchestrator__ is a system that automates the deployment, scaling, networking, and management of containerized applications. 

It plays a crucial role in production environments where services must remain available, resilient, and easily updatable.

Without an orchestrator, managing hundreds or thousands of containers manually would be error-prone, inefficient, and unsustainable — especially in environments that demand high availability, dynamic scaling, and automated recovery from failure.

Orchestration solves key challenges like __service discovery, load balancing, health checks, resource scheduling, automated rollouts and rollbacks, and self-healing of applications__ . 

It also provides __centralized control__ over __distributed infrastructure__,

enabling teams to enforce __consistency, optimize resource usage__, and __respond to real-time changes__ in application demand or infrastructure state.


Kubernetes (K8s) has emerged as the most popular and powerful orchestrator, designed to manage complex, distributed systems at scale. Its key features include:

* __Declarative configuration__: Define desired system state using YAML/JSON, letting K8s reconcile reality with the declared spec.

* __Self-healing__: Automatically restarts failed containers, replaces unresponsive Pods, and evicts unhealthy nodes.

* __Horizontal scaling__: Adjusts the number of running Pods based on CPU/memory usage or custom metrics.

* __Rolling updates and rollbacks__: Enables zero-downtime deployments with built-in version control and safe rollback in case of failure.

* __Persistent volume management__: Abstracts storage resources and dynamically provisions volumes for stateful workloads.

* __Service discovery and DNS__: Exposes services with internal or external networking via stable DNS names and load balancing.

* __Extensibility__: Operators, CRDs, and webhooks make K8s highly customizable and adaptable to any workload or platform need.

From a DevOps and reliability engineering perspective, Kubernetes provides the automation, observability, and operational control needed to confidently run applications in production - reducing human error, accelerating delivery, and improving system resilience.



