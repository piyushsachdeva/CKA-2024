# Assignment: Migrating from Ingress to Gateway API

## Overview

In this assignment, you will learn how to migrate an existing Kubernetes Ingress resource to the newer Gateway API. The Gateway API provides a more extensible and feature-rich way to configure traffic routing in Kubernetes clusters.


## Requirements

- A Kubernetes cluster (version 1.24+)
- kubectl installed and configured
- Basic understanding of Kubernetes networking concepts
- Helm and kustomize (optional, for installing controllers)

## Tasks

### 1. Prepare Your Environment

- Deploy a sample application with a service
- Create TLS certificates for secure communication

### 2. Create and Test an Ingress Resource

- Set up an Ingress controller (e.g., NGINX Ingress Controller)
- Create an Ingress resource that routes traffic to your services:
  - Host: `gateway.web.k8s.local`
  - Path `/` should route to the web frontend service
  - Configure TLS for secure communication
- Test the Ingress configuration to ensure it works correctly

### 3. Install and Configure Gateway API

- Install Gateway API CRDs in your cluster
- Deploy a Gateway API controller (e.g., NGINX Gateway Fabric)
- Create the necessary Gateway API resources:
  - GatewayClass
  - Gateway
  - HTTPRoute(s)
- Ensure proper TLS configuration with the Gateway resources

### 4. Verify the Migration

- Test the new Gateway API configuration
- Compare traffic routing between Ingress and Gateway API
- Ensure both configurations work correctly before removing the old Ingress resource

### 5. Clean Up

- Once verified, remove the old Ingress resource
- Document any issues encountered and how they were resolved

