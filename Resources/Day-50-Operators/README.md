# Day 50 - Kubernetes Operators

## 1. Understanding Kubernetes Operators

1. **Traditional vs Operator Pattern**

Traditional: Deploy application → Manual configuration → Manual scaling/updates

Operator: Deploy operator → Declare desired state → Operator handles everything

2. **Key Components**

- Custom Resource Definitions (CRDs): Extend Kubernetes API with new resource types

- Custom Resources (CRs): Instances of CRDs

- Controller: Watches CRs and reconciles actual state with desired state

3. **Why Use Operators?**

- Automate complex application lifecycle management
- Encode operational knowledge into code
- Provide consistent deployment and management experience
- Handle day-2 operations (backup, restore, scaling, updates)

The cert-manager Operator is a prime example. Instead of manually obtaining, renewing, and managing TLS certificates for your applications, you simply define Issuer and Certificate Custom Resources. The cert-manager Operator then watches these CRs and automatically handles the entire certificate lifecycle for you, including issuance from various sources (like Let's Encrypt), renewal, and even injecting them into Kubernetes Secrets.

### Reconciliation: how an operator works

The fundamental mechanism by which a Kubernetes Operator works is called reconciliation. It refers to the continuous process where the Operator (specifically, its controller component) observes the actual state of resources in the Kubernetes cluster and constantly compares it to the desired state as defined in its Custom Resources.

Here's a breakdown of the reconciliation loop:

1. **Desired State (Custom Resources):** You, as the user, declaratively define the desired state of your application or component by creating or updating Custom Resources (e.g., a Certificate CR indicating you want a certificate for my-app.example.com).

2. **Actual State (Kubernetes Resources):** The Operator continuously monitors the Kubernetes API for the current actual state of the relevant Custom Resources and the standard Kubernetes resources (like Pods, Deployments, Secrets, Services) that it manages.

3. **Reconciliation Loop:** The Operator runs a continuous "reconciliation loop" where it performs the following:
   - **Observes:** It fetches the current actual state of all relevant Kubernetes resources.
   - **Compares:** It compares this actual state with the desired state specified in your Custom Resources.
   - **Acts:** If there's any discrepancy (e.g., a certificate is missing, needs renewal, or a secret doesn't exist), the Operator takes the necessary imperative actions to bring the actual state in line with the desired state. This could involve creating new secrets, updating configurations, or interacting with external services (like a certificate authority).
   - **Loops:** This process is cyclical and continuous. The Operator keeps running this loop, ensuring that your declared desired state is maintained over time, even if something changes unexpectedly in the cluster.


### Introduction to Operator Lifecycle Manager (OLM)

While Operators can be installed manually (e.g., using kubectl apply or Helm), the Operator Lifecycle Manager (OLM) simplifies the process of installing, upgrading, and managing Operators and their associated Custom Resource Definitions (CRDs) and Custom Resources (CRs). OLM acts as a "meta-operator" that manages other Operators, providing a consistent way to discover and deploy them in your cluster.


## 2. Prerequisites

Before you begin, please ensure you have the following installed and configured:

**A local Kubernetes cluster:**
- **Minikube:** Install it from https://minikube.sigs.k8s.io/docs/start/
- **Kind:** Install it from https://kind.sigs.k8s.io/docs/user/quick-start/
- The kubeadm cluster from Day 27 works as well

**kubectl:** The Kubernetes command-line tool. Ensure it's configured to connect to your local cluster.

**curl:** For downloading OLM installation script.

**Basic Kubernetes Knowledge:**
- Familiarity with kubectl commands (e.g., get pods, get svc, describe).
- Understanding of basic Kubernetes resources like Pods, Deployments, Services, and Namespaces.

## 3. Steps to set up the cert-manager operator


### Step 3.1: Install Operator Lifecycle Manager (OLM)

We will install OLM in your cluster. This will create a new namespace `olm` and deploy the OLM components.
[source](https://operatorhub.io/operator/cert-manager)

```bash
# Install OLM
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.46.0/install.sh | bash -s v0.46.0
```

Wait for OLM to be ready. You can check the pods in the `olm` namespace:

```bash
kubectl get pods -n olm
```

Ensure all OLM-related pods (e.g., `olm-operator`, `catalog-operator`, `packageserver`) are in a `Running` state. The install also creates a namespace called `operators` with an OperatorGroup named `global-operators`, which is where we install the operator next.

```bash
# Install the operator. This creates a Subscription named my-cert-manager in the operators namespace
kubectl create -f https://operatorhub.io/install/cert-manager.yaml
```

A **Subscription** tells OLM which operator you want and from which catalog and channel. OLM then installs the operator and keeps it up to date. The installed version of an operator is represented by an object called a **ClusterServiceVersion (CSV)**.

Wait for the cert-manager operator to be in the `Succeeded` state. This can take a couple of minutes.
```bash
kubectl get subscription -n operators
kubectl get csv -n operators -w
```

> Note: The video uses OLM v0.32.0. The command above uses v0.46.0, the latest release of OLM v0 at the time of this update. Check the [releases page](https://github.com/operator-framework/operator-lifecycle-manager/releases) for the current one.

### Step 3.2: Verify the Installation and Observe Operator Components

After the Subscription is created, OLM will automatically deploy the cert-manager Operator and its associated resources.

> Note: An earlier version of these notes also created a second OperatorGroup in the `operators` namespace. Do not do that. OLM allows only one OperatorGroup per namespace, and with two of them the CSV fails with the reason `TooManyOperatorGroups`. The `global-operators` OperatorGroup that OLM created is all that is needed.

**Check Operator Pods:**
You should see the cert-manager-operator pod (deployed by OLM) and then the actual cert-manager, cert-manager-cainjector, and cert-manager-webhook pods (deployed by the cert-manager operator itself).

```bash
kubectl get pods -n operators
```

Look for pods named something like `cert-manager-operator-...`, `cert-manager-...`, `cert-manager-cainjector-...`, and `cert-manager-webhook-...`.

**Inspect Custom Resource Definitions (CRDs):**
OLM handles the installation of CRDs. The cert-manager Operator introduces several CRDs into your cluster.

```bash
kubectl get crds | grep cert-manager
```

You should see CRDs like `certificates.cert-manager.io`, `issuers.cert-manager.io`, `clusterissuers.cert-manager.io`, and `certificaterequests.cert-manager.io`.

**Inspect Custom Resources (CRs) (Initial State):**
At this point, you won't see any Issuer or Certificate CRs yet, as we haven't created any.

```bash
kubectl get issuer -n default
kubectl get certificate -n default
```

(You should see "No resources found" or similar, which is expected.)

### Step 3.3: Create an Issuer and a Certificate

Now, let's create some cert-manager Custom Resources and see the Operator in action. We'll create a simple self-signed Issuer and then a Certificate that uses it.

**Create a self-signed Issuer:**
This Issuer will be responsible for signing certificates within the default namespace.

```yaml
# selfsigned-issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: default
spec:
  selfSigned: {}
```

Apply this manifest:
```bash
kubectl apply -f selfsigned-issuer.yaml
```

**Verify the Issuer is ready:**
```bash
kubectl get issuer selfsigned-issuer -n default
```

Look for STATUS to be `Ready`.

**Create a Certificate:**
This Certificate resource tells cert-manager to issue a certificate for `my-app.example.com` using our `selfsigned-issuer` and store it in a Kubernetes Secret named `my-app-tls`.

```yaml
# my-app-certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-app-certificate
  namespace: default
spec:
  secretName: my-app-tls
  dnsNames:
  - my-app.example.com
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
```

Apply this manifest:
```bash
kubectl apply -f my-app-certificate.yaml
```

### Step 3.4: Observe Operator Reconciliation and Secret Creation

Now, let's see the cert-manager Operator in action.

**Check the Certificate status:**
The cert-manager Operator will process the Certificate resource.

```bash
kubectl get certificate my-app-certificate -n default
```

Initially, its READY status might be `False`, then change to `True` as the certificate is issued.

**Inspect the created Secret:**
Once the Certificate is ready, cert-manager will have created a TLS Secret containing the generated certificate and private key.

```bash
kubectl get secret my-app-tls -n default
```

You should see a Secret of type `kubernetes.io/tls`. You can describe it to see more details (though the actual certificate data will be base64 encoded).

```bash
kubectl describe secret my-app-tls -n default
```

**View cert-manager logs (Optional, but Recommended):**
To see the Operator's internal workings, you can view the logs of the cert-manager controller pod.

```bash
kubectl logs -f -n operators $(kubectl get pods -n operators -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.name}')
```

You'll see log entries indicating that it's processing the Certificate resource, creating CertificateRequest objects, and finally creating the TLS Secret. This demonstrates the "controller" part of the Operator pattern.

**Force Operator Reconciliation by Restarting the Pod (Advanced/Troubleshooting):**
Operators continuously watch for changes in Custom Resources. However, sometimes for debugging or to force a re-evaluation, you might want to restart the operator's pod. When the cert-manager controller pod restarts, it will re-read all relevant Custom Resources and reconcile their desired state with the actual state in the cluster.

First, identify the cert-manager controller pod:
```bash
kubectl get pods -n operators -l app.kubernetes.io/component=controller
```

Then, delete the pod. Kubernetes will automatically recreate it because it's managed by a Deployment.
```bash
kubectl delete pod <cert-manager-controller-pod-name> -n operators
```

Replace `<cert-manager-controller-pod-name>` with the actual name you found in the previous command (e.g., `cert-manager-7c8d9f-abcde`).

After the new pod starts, you can again view its logs (as shown above) to observe it re-processing existing Issuer and Certificate resources. This demonstrates the resilience and self-healing nature of Kubernetes Deployments combined with the Operator's reconciliation loop.

### Step 3.5: Clean Up

Clean up your cluster after completing the assignment.

**Delete the Custom Resources:**
Always delete your custom resources before uninstalling the operator.

```bash
kubectl delete -f my-app-certificate.yaml
kubectl delete -f selfsigned-issuer.yaml
```

**Delete the cert-manager Subscription and the installed operator (CSV):**
```bash
kubectl delete -f https://operatorhub.io/install/cert-manager.yaml
kubectl delete csv --all -n operators
```

**Uninstall OLM:**
```bash
kubectl delete -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.46.0/olm.yaml
kubectl delete -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.46.0/crds.yaml
```

This removes the `olm` and `operators` namespaces as well.

## 4. Other ways to install an operator

OLM is one way to install operators, and it is the default on OpenShift. On plain Kubernetes clusters, most operators are installed with a Helm chart or with a manifest that contains the CRDs, the RBAC rules and the controller Deployment. For example, the Calico install in Day 27 uses the Tigera operator: you apply the operator manifest, then create an `Installation` custom resource, and the operator installs Calico for you. Whichever way an operator is installed, you work with it in the same way:

```bash
kubectl get crd                                  # which new resource types did it add?
kubectl api-resources --api-group=<group>        # what are they called?
kubectl explain <kind>.spec                      # which fields can I set?
kubectl get <kind> -A                            # which custom resources exist?
kubectl logs -n <namespace> deploy/<operator>    # what is the controller doing?
```
