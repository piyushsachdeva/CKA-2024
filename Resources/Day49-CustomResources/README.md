# Kubernetes Custom Resources and CRDs with sample-controller

This guide provides a step-by-step solution to demonstrate the creation and management of Custom Resources (CRs) and Custom Resource Definitions (CRDs) in Kubernetes, using the kubernetes/sample-controller as an example.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Step-by-Step Guide](#step-by-step-guide)
  - [Step 1: Clone the sample-controller Repository](#step-1-clone-the-sample-controller-repository)
  - [Step 2: Build and Run the Sample Controller](#step-2-build-and-run-the-sample-controller)
  - [Step 3: Create the CustomResourceDefinition (CRD)](#step-3-create-the-customresourcedefinition-crd)
  - [Step 4: Create a Custom Resource (CR) of Type Foo](#step-4-create-a-custom-resource-cr-of-type-foo)
  - [Step 5: Verify the Created Resources](#step-5-verify-the-created-resources)
  - [Step 6: Clean Up (Optional)](#step-6-clean-up-optional)
- [Understanding the Components](#understanding-the-components)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- A running Kubernetes cluster (e.g., Minikube, Kind, or a cloud-managed cluster)
- `kubectl` configured to connect to your cluster
- Go programming language installed (version 1.16 or higher is recommended)
- Basic understanding of Kubernetes concepts (Pods, Deployments, Services)

## Step-by-Step Guide

### Step 1: Clone the sample-controller Repository

First, clone the kubernetes/sample-controller repository to your local machine and navigate into its directory.

```bash
git clone https://github.com/kubernetes/sample-controller
cd sample-controller
```

### Step 2: Build and Run the Sample Controller

Build the controller executable and then run it. The controller will watch for Foo custom resources and create Deployments based on them.

```bash
# Ensure you have go client installed
sudo apt-get update -y
sudo apt install golang-go -y

sed -i 's/go 1\.24\.0/go 1.18/' go.mod
sed -i '/^godebug/d' go.mod
go mod tidy

# Build the sample-controller from the source code
go build -o sample-controller .

# Run the sample-controller.
# Keep this running in a separate terminal or in the background.
./sample-controller -kubeconfig=$HOME/.kube/config
```

**Note:** Keep this process running in a separate terminal window or run it in the background, as it needs to continuously monitor for changes to Foo resources.

### Step 3: Create the CustomResourceDefinition (CRD)

Now, create the CustomResourceDefinition for the Foo resource. This tells Kubernetes about the new Foo API type.

```bash
# Create a CustomResourceDefinition for Foo
kubectl create -f artifacts/examples/crd-status-subresource.yaml
```

**Explanation:** This command registers the Foo resource with your Kubernetes API server. You can verify its creation:

```bash
# Check if the CRD has been created
kubectl get crd | grep foo
```

You should see an output similar to `foos.samplecontroller.k8s.io`.

### Step 4: Create a Custom Resource (CR) of Type Foo

Next, create an instance of your Foo custom resource. The sample-controller (running from Step 2) will detect this new Foo object and create a Kubernetes Deployment according to its specification.

```bash
# Create a custom resource of type Foo
kubectl create -f artifacts/examples/example-foo.yaml
```

**Content of `artifacts/examples/example-foo.yaml`:**

```yaml
apiVersion: samplecontroller.k8s.io/v1alpha1
kind: Foo
metadata:
  name: example-foo
spec:
  deploymentName: example-foo-deployment # The controller will create a deployment with this name
  replicas: 1
```

### Step 5: Verify the Created Resources

After creating the Foo custom resource, the sample-controller should have automatically created a standard Kubernetes Deployment.

```bash
# Check the custom resource instance
kubectl get Foo

# Check deployments created through the custom resource
kubectl get deployments
```

You should see both your `example-foo` custom resource and an `example-foo-deployment` (or similar name, depending on the controller's logic) listed.

You can also get more details about the created deployment:

```bash
# Describe the deployment created by the controller
kubectl describe deployment example-foo-deployment
```

### Step 6: Verify the CRD

Check the fields of CRD

```bash
kubectl explain Foo.spec.deploymentName
kubectl explain Foo.spec.replicas
```

### Step 7: Clean Up (Optional)

To clean up the resources created during this demo:

```bash
# Delete the custom resource instance
kubectl delete -f artifacts/examples/example-foo.yaml

# Delete the CustomResourceDefinition
kubectl delete -f artifacts/examples/crd-status-subresource.yaml
```

### Exam questions - 1

```bash
# List all the cert-manager CRD's

kubectl describe crd | grep certificates

# Extract the documentation of subject specification field
kubectl explain certificates.spec.subject
```
### Exam questions - 2

#### Install a tool such as cert-manager without CRDs

```bash
helm repo add jetstack https://charts.jetstack.io --force-update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.2 \
  --set crds.enabled=false
```

**Remember to stop the sample-controller process** that you started in Step 2 (e.g., by pressing `Ctrl+C` in its terminal).

This completes the demonstration of creating and managing custom resources and custom resource definitions in Kubernetes.

## Understanding the Components

### What is a Custom Resource Definition (CRD)?

A CRD is a Kubernetes API extension that allows you to define custom resource types. It tells Kubernetes:
- What the new resource should be called
- What fields it should have
- How it should be validated
- What versions are supported

### What is a Custom Resource (CR)?

A Custom Resource is an instance of a CRD. It's the actual object that contains your specific configuration data.

### What does the sample-controller do?

The sample-controller is a Kubernetes controller that:
- Watches for changes to Foo custom resources
- Creates and manages Deployments based on the Foo resource specifications
- Updates the status of Foo resources to reflect the current state
- Implements the controller pattern for custom resources


### Useful Commands for Debugging

```bash
# Check controller logs (if running as a pod)
kubectl logs -f <controller-pod-name>

# Get detailed information about the CRD
kubectl describe crd foos.samplecontroller.k8s.io

# Check the status of your Foo resource
kubectl describe foo example-foo

# List all custom resources in the cluster
kubectl get crd
```
