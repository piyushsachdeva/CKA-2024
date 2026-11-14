# Day 47 - Gateway API: Solution

Docs: https://gateway-api.sigs.k8s.io (this site is allowed in the CKA exam)

> Note: The video uses NGINX Gateway Fabric 1.6. From version 2.0, NGINX Gateway Fabric works differently: the controller no longer handles the traffic itself. Every time you create a Gateway, it starts a separate NGINX Deployment and Service for that Gateway. The steps below have been updated for version 2.8.1, so a few commands (setting the NodePort, the name of the Service) are different from what you see in the video. The Gateway API objects themselves (GatewayClass, Gateway, HTTPRoute) are the same.

## Key Concepts

The Gateway API is the successor of Ingress. It splits the job of one Ingress object into three objects, each owned by a different role:

| Object | Who usually owns it | What it does |
|---|---|---|
| **GatewayClass** | Infrastructure provider | Names the controller that implements the Gateway API. It plays the same role as an IngressClass |
| **Gateway** | Cluster admin | The entry point for traffic: which ports, protocols, hostnames and TLS certificates to listen on, and which namespaces may attach routes |
| **HTTPRoute** | Application developer | The routing rules: which hostnames and paths go to which Service |

The Gateway API objects are CRDs. They are not part of a default Kubernetes install, so you install the CRDs first and then a controller that implements them.

## Prerequisites

- A Kubernetes cluster (the kubeadm cluster from Day 27, minikube, kind, or a playground such as [Killercoda](https://killercoda.com/playgrounds/scenario/kubernetes))
- kubectl installed and configured
- Basic understanding of Kubernetes concepts such as pod, deployment, Ingress, services etc

> Note: If you are using kind, create the cluster with `extraPortMappings` for port 30080 (see the [Day09](../Day09) readme), otherwise the NodePort is not reachable from your machine.

## Step 1: Install Gateway API Resources

First, we need to install the Gateway API CRDs (Custom Resource Definitions):

```bash
# Install Gateway API resources
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.8.1" | kubectl apply -f -

# Verify installation
kubectl get crd | grep gateway.networking.k8s.io
```

Expected output should include CRDs like `gatewayclasses.gateway.networking.k8s.io`, `gateways.gateway.networking.k8s.io`, and `httproutes.gateway.networking.k8s.io`.

## Step 2: Install NGINX Gateway Fabric

Next, we'll install NGINX Gateway Fabric as our Gateway API controller:

```bash
# Deploy NGINX Gateway Fabric CRDs
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.8.1/deploy/crds.yaml

# Deploy NGINX Gateway Fabric
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.8.1/deploy/nodeport/deploy.yaml

# Verify the deployment
kubectl get pods -n nginx-gateway
```

You should see the NGINX Gateway Fabric pod running:

```
NAME                             READY   STATUS    RESTARTS   AGE
nginx-gateway-5d4d9b47c4-x8z6l   1/1     Running   0          30s
```

The install also creates a GatewayClass named `nginx` for you:

```bash
kubectl get gatewayclass
```

```
NAME    CONTROLLER                                   ACCEPTED   AGE
nginx   gateway.nginx.org/nginx-gateway-controller   True       30s
```

This is what that GatewayClass looks like. You do not need to apply it, it is shown here so that you know the object:

```yaml
# GatewayClass defines the controller that implements the Gateway API
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
```

## Step 3: Set fixed NodePort values

The settings for the NGINX Service that gets created for each Gateway are kept in an object of kind `NginxProxy`. Patch it so that the Gateway listener on port 80 is always exposed on NodePort 30080, and port 443 on 30081:

```bash
kubectl patch nginxproxy nginx-gateway-proxy-config -n nginx-gateway --type merge -p '
spec:
  kubernetes:
    service:
      type: NodePort
      externalTrafficPolicy: Cluster
      nodePorts:
      - port: 30080
        listenerPort: 80
      - port: 30081
        listenerPort: 443
'
```

> Note: `externalTrafficPolicy: Cluster` lets you reach the NodePort on any node. The default of this install is `Local`, where only the node that runs the NGINX pod answers.

## Step 4: Create the Gateway

Save the following YAML to a file named `gateway.yaml`:

```yaml
# Gateway resource defines the listener and ports
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: nginx-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
```

`allowedRoutes.namespaces.from: All` lets HTTPRoutes from every namespace attach to this Gateway. The default is `Same`, which allows only routes from the Gateway's own namespace.

Apply the configuration:

```bash
kubectl apply -f gateway.yaml

# Verify resources
kubectl get gateway -n nginx-gateway
kubectl get pods,svc -n nginx-gateway
```

You should see the Gateway with `PROGRAMMED` as `True`, and a new Deployment and Service named `<gateway-name>-nginx`, which handle the traffic for this Gateway:

```
NAME            CLASS   ADDRESS        PROGRAMMED   AGE
nginx-gateway   nginx   10.96.188.84   True         15s

NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/nginx-gateway         ClusterIP   10.96.12.200   <none>        443/TCP        2m
service/nginx-gateway-nginx   NodePort    10.96.188.84   <none>        80:30080/TCP   15s
```

## Step 5: Create a pod named frontend-app that exposes a container on port 8080

```bash
kubectl run frontend-app --image=nginxinc/nginx-unprivileged:stable-alpine --port=8080 --labels=app=frontend
```

## Step 6: Create a service that exposes frontend-app on port 80 with target port 8080

```bash
kubectl expose pod frontend-app --name=frontend-svc --port=80 --target-port=8080
kubectl get endpointslices -l kubernetes.io/service-name=frontend-svc
```

## Step 7: Expose the Frontend Service

Now, let's create an HTTPRoute to route traffic to the `frontend-svc` service. Save the following YAML to `frontend-route.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: default
spec:
  parentRefs:
  - name: nginx-gateway
    namespace: nginx-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-svc
      port: 80
```

- `parentRefs` is the Gateway that this route attaches to. The `namespace` is needed here because the Gateway is in a different namespace than the route.
- `backendRefs` is the Service that receives the traffic. It must be in the same namespace as the HTTPRoute, unless a ReferenceGrant allows otherwise.

Apply the configuration:

```bash
kubectl apply -f frontend-route.yaml

# Verify the HTTPRoute
kubectl get httproute frontend-route
kubectl describe httproute frontend-route
```

You should see the HTTPRoute created:

```
NAME             HOSTNAMES   AGE
frontend-route               30s
```

The `describe` command should show the conditions `Accepted: True` and `ResolvedRefs: True` under `Status`.

## Step 8: Test the Configuration

To test if your configuration works:

```bash
# Get the internal IP of the first node
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Access the application
curl http://$NODE_IP:30080/
```

You should see the nginx welcome page from the frontend application. On kind, use `curl http://localhost:30080/`.

## More HTTPRoute rules

Route by hostname and path, and split traffic between two versions of a service:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: shop-route
spec:
  parentRefs:
  - name: nginx-gateway
    namespace: nginx-gateway
  hostnames:
  - shop.example.com
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /cart
    backendRefs:
    - name: cart-svc
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: shop-v1
      port: 80
      weight: 90
    - name: shop-v2
      port: 80
      weight: 10
```

## Troubleshooting

If you encounter issues:

1. **Check Gateway status**:
   ```bash
   kubectl describe gateway nginx-gateway -n nginx-gateway
   ```
   Look for any errors in the status section. Check that `gatewayClassName` matches an existing GatewayClass.

2. **Check HTTPRoute status**:
   ```bash
   kubectl describe httproute <route-name>
   ```
   Check if the route is accepted by the gateway. If it is not, the usual causes are a wrong name or namespace in `parentRefs`, or a Gateway whose `allowedRoutes` does not allow the namespace of the route.

3. **Check NGINX Gateway Fabric logs**:
   ```bash
   kubectl logs -n nginx-gateway deployment/nginx-gateway
   kubectl logs -n nginx-gateway deployment/nginx-gateway-nginx
   ```
   The first one is the controller, the second one is the NGINX that handles the traffic.

4. **Verify services exist and have endpoints**:
   ```bash
   kubectl get svc,endpointslices
   ```
   Make sure your services have endpoints.

## Advantages of Gateway API over Traditional Ingress

1. **More expressive routing** - Header-based routing, traffic splitting, redirects and rewrites are part of the API. With Ingress, they need controller-specific annotations
2. **Separation of concerns** - Different teams can manage different resources
3. **Standardization** - The same manifests work with every controller that passes the conformance tests
4. **More than HTTP** - There are route types for gRPC, TLS, TCP and UDP as well

## Clean Up

```bash
kubectl delete httproute frontend-route
kubectl delete svc frontend-svc
kubectl delete pod frontend-app
kubectl delete gateway nginx-gateway -n nginx-gateway
```
