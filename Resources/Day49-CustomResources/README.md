# Day 49 - Kubernetes Custom Resources and CRDs

This guide shows how to create and manage Custom Resource Definitions (CRDs) and Custom Resources (CRs) in Kubernetes. Part 1 needs only `kubectl` and covers what you need for the CKA exam. Part 2 runs the kubernetes/sample-controller, as shown in the video, to see a controller act on a custom resource.

## Table of Contents

- [Understanding the Components](#understanding-the-components)
- [Part 1: Create your own CRD and Custom Resource](#part-1-create-your-own-crd-and-custom-resource)
- [Part 2: CRD with a controller (sample-controller)](#part-2-crd-with-a-controller-sample-controller)
- [Part 3: CRDs installed by other tools](#part-3-crds-installed-by-other-tools)
- [Useful Commands](#useful-commands)

## Understanding the Components

### What is a Custom Resource Definition (CRD)?

A CRD is a Kubernetes API extension that allows you to define custom resource types. It tells Kubernetes:
- What the new resource should be called (kind, plural name, short names)
- Which API group and versions it has
- Whether it is namespaced or cluster-scoped
- What fields it should have and how they should be validated (an OpenAPI v3 schema)

### What is a Custom Resource (CR)?

A Custom Resource is an instance of a CRD. It's the actual object that contains your specific configuration data. Once the CRD exists, you work with custom resources the same way as with built-in objects: `kubectl get`, `describe`, `apply`, `delete`, RBAC and so on.

### What is a controller?

A CRD and its custom resources only store data in etcd. Nothing happens in the cluster until a controller watches these objects and acts on them. A CRD together with its controller is what is called an operator (see the [Day-50](../Day-50-Operators) folder).

## Part 1: Create your own CRD and Custom Resource

### Step 1: Create the CRD

Save the following as `crontab-crd.yaml`. The name of a CRD must be `<plural>.<group>`.

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["cronSpec", "image"]
            properties:
              cronSpec:
                type: string
              image:
                type: string
              replicas:
                type: integer
                minimum: 1
                maximum: 10
    additionalPrinterColumns:
    - name: Schedule
      type: string
      jsonPath: .spec.cronSpec
    - name: Replicas
      type: integer
      jsonPath: .spec.replicas
```

```bash
kubectl apply -f crontab-crd.yaml
kubectl get crd crontabs.stable.example.com
kubectl api-resources --api-group=stable.example.com
```

### Step 2: Create a Custom Resource

Save the following as `my-crontab.yaml`:

```yaml
apiVersion: stable.example.com/v1
kind: CronTab
metadata:
  name: my-new-cron-object
spec:
  cronSpec: "* * * * */5"
  image: my-awesome-cron-image
  replicas: 2
```

```bash
kubectl apply -f my-crontab.yaml
kubectl get crontab
kubectl get ct
kubectl describe ct my-new-cron-object
```

### Step 3: See the validation at work

Change `replicas` to `20` in `my-crontab.yaml` and apply it again. The API server rejects it, because the schema of the CRD allows a maximum of 10.

### Step 4: Read the documentation of the fields

```bash
kubectl explain crontab
kubectl explain crontab.spec
kubectl explain crontab.spec.replicas
```

### Step 5: Clean Up

Deleting a CRD also deletes all the custom resources of that type.

```bash
kubectl delete -f my-crontab.yaml
kubectl delete -f crontab-crd.yaml
```

## Part 2: CRD with a controller (sample-controller)

This part is optional. It needs the Go toolchain, and nothing in the exam asks you to build a controller.

### Prerequisites

- A running Kubernetes cluster and `kubectl` configured to connect to it
- Go installed. The sample-controller follows the newest Go release, so install the latest version from https://go.dev/dl/. The Go version that `apt` installs on Ubuntu is usually too old.

> Note: The video downgrades the Go version in `go.mod` with `sed` so that the code builds with the Go package from `apt`. That workaround no longer works, because the Go version in `go.mod` changes with every release of the repository. Installing a current Go version is the reliable way.

### Step 1: Clone the sample-controller Repository

```bash
git clone https://github.com/kubernetes/sample-controller
cd sample-controller
```

### Step 2: Build and Run the Sample Controller

Build the controller executable and then run it. The controller will watch for Foo custom resources and create Deployments based on them.

```bash
go version

# Build the sample-controller from the source code
go build -o sample-controller .

# Run the sample-controller.
# Keep this running in a separate terminal or in the background.
./sample-controller -kubeconfig=$HOME/.kube/config
```

The controller logs errors until the CRD from the next step exists. That is expected.

### Step 3: Create the CustomResourceDefinition (CRD)

In a second terminal, from the `sample-controller` directory, create the CustomResourceDefinition for the Foo resource. This tells Kubernetes about the new Foo API type.

```bash
# Create a CustomResourceDefinition for Foo
kubectl create -f artifacts/examples/crd-status-subresource.yaml

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
  deploymentName: example-foo # The controller will create a deployment with this name
  replicas: 1
```

### Step 5: Verify the Created Resources

After creating the Foo custom resource, the sample-controller should have automatically created a standard Kubernetes Deployment.

```bash
# Check the custom resource instance
kubectl get foo

# Check deployments created through the custom resource
kubectl get deployments

# Describe the deployment created by the controller
kubectl describe deployment example-foo
```

Now change `replicas` to 3 with `kubectl edit foo example-foo` and watch the controller scale the Deployment. Then delete the Deployment and watch the controller create it again. This is the reconciliation loop.

### Step 6: Verify the CRD

Check the fields of the CRD

```bash
kubectl explain foo.spec.deploymentName
kubectl explain foo.spec.replicas
```

### Step 7: Clean Up

```bash
# Delete the custom resource instance
kubectl delete -f artifacts/examples/example-foo.yaml

# Delete the CustomResourceDefinition
kubectl delete -f artifacts/examples/crd-status-subresource.yaml
```

**Remember to stop the sample-controller process** that you started in Step 2 (e.g., by pressing `Ctrl+C` in its terminal).

## Part 3: CRDs installed by other tools

Most of the CRDs that you meet in a real cluster, and in the exam, come with a tool such as cert-manager, Calico or a Gateway API controller. The tasks are usually about finding the CRDs and reading their fields.

### Practice task 1

```bash
# List all the cert-manager CRDs and write the list to a file
kubectl get crd | grep cert-manager > /tmp/crds.txt

# Extract the documentation of the subject field of the Certificate resource and write it to a file
kubectl explain certificate.spec.subject > /tmp/subject.txt
```

### Practice task 2

#### Install a tool such as cert-manager with Helm, with and without its CRDs

```bash
helm repo add jetstack https://charts.jetstack.io --force-update

# install the chart together with its CRDs
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.21.3 \
  --set crds.enabled=true
```

To install the chart **without** the CRDs, set `crds.enabled=false`, which is also the default of this chart. In that case the CRDs must already be there, otherwise the cert-manager pods start but cannot do anything. You can install them on their own first:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.21.3/cert-manager.crds.yaml
```

> Note: CRDs that a chart keeps in its `crds/` directory are installed once, and Helm never upgrades or deletes them along with the release. That is why many charts, cert-manager included, give you a value to switch the CRDs on or off, and why CRDs are often managed separately from the chart.

## Useful Commands

```bash
# List all the CRDs in the cluster
kubectl get crd

# Get detailed information about a CRD
kubectl describe crd foos.samplecontroller.k8s.io

# See the full definition, including the schema
kubectl get crd foos.samplecontroller.k8s.io -o yaml

# List every resource type of an API group
kubectl api-resources --api-group=cert-manager.io

# List all the custom resources of a type in all namespaces
kubectl get certificates -A

# Check the status of a custom resource
kubectl describe foo example-foo
```
