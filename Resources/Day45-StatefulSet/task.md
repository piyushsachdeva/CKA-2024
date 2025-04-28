# CKA StatefulSet Assignment Day45

## Overview

In this assignment, you will learn how to deploy and scale a stateful application in Kubernetes using StatefulSets.

## Prerequisites

- A working Kubernetes cluster (minikube, kind, [kodekloud sandbox](https://kodekloud.com/public-playgrounds) or a cloud provider's managed Kubernetes)
- kubectl command-line tool installed and configured
- Basic understanding of Kubernetes concepts (Pods, Services, Deployments)

## Assignment Tasks

### 1. Set up the Environment

- Ensure your Kubernetes cluster is up and running
- Verify kubectl connection to your cluster

### 2. Create a Headless Service

Create a headless service for your MongoDB StatefulSet deployment. A headless service is required to provide network identity to each Pod in the StatefulSet.

### 3. Create PersistentVolumes and StorageClass

Configure persistent storage for your StatefulSet by:
- Creating a StorageClass
- Setting up 5 PersistentVolumes to be used by your StatefulSet

### 4. Deploy a MongoDB StatefulSet

Create and deploy a StatefulSet manifest that:
- Uses the MongoDB image
- References the headless service created earlier
- Configures persistent storage using volumeClaimTemplates
- Starts with 3 replicas

### 5. Verify and Test the Deployment

- Confirm all Pods are running
- Verify PersistentVolumeClaims are bound to your PersistentVolumes
- Connect to one of the MongoDB instances and create some sample data
- Test persistence by deleting a Pod and verifying data remains after the Pod is recreated

### 6. Scale the StatefulSet

- Scale the StatefulSet to 5 replicas
- Observe the ordered creation of new Pods
- Verify the new Pods have their own PersistentVolumeClaims bound to PersistentVolumes

### 7. Clean Up Resources

Clean up all resources created during this assignment, observe the deleting happens sequentially
