# Day 46 - CKA Pod Priority and Preemption Assignment

## Overview

In this assignment, you will learn about Pod Priority and Preemption in Kubernetes. You'll create different priority classes, assign them to pods, 
and observe how Kubernetes handles scheduling when resources are constrained.

## Prerequisites

- A Kubernetes cluster (minikube, kind, or any other Kubernetes cluster)
- kubectl installed and configured
- Basic understanding of Kubernetes pods and deployments

## Assignment Tasks

1. Create three priority classes with different priority values
2. Deploy pods with different priority classes
3. Create a resource-constrained deployment with 5 replicas and resource requests set
4. Check your node resources
5. Deploy a high-priority pod with high resource utilization and observe preemption
6. Document your observations
