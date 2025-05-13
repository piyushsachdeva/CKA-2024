# Day 47 solution

## Prerequisites

- A Kubernetes cluster (this guide works with minikube, kind, or playground such as [kodekloud](https://kode.wiki/4d24Q9Z) or cloud providers)
- kubectl installed and configured
- Basic understanding of Kubernetes concepts such as pod, deployment, Ingress, services etc

## Step 1: Install Gateway API Resources

First, we need to install the Gateway API CRDs (Custom Resource Definitions):

```bash
# Install Gateway API resources
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.5.1" | kubectl apply -f -

# Verify installation
kubectl get crd | grep gateway
```

Expected output should include CRDs like `gatewayclasses.gateway.networking.k8s.io`, `gateways.gateway.networking.k8s.io`, and `httproutes.gateway.networking.k8s.io`.

## Step 2: Configure NGINX Gateway Fabric

Next, we'll install NGINX Gateway Fabric as our Gateway API controller:

```bash
# Deploy NGINX Gateway Fabric CRDs
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v1.6.1/deploy/crds.yaml

# Deploy NGINX Gateway Fabric
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v1.6.1/deploy/nodeport/deploy.yaml

# Verify the deployment
kubectl get pods -n nginx-gateway
```

You should see the NGINX Gateway Fabric pods running:

```
NAME                             READY   STATUS    RESTARTS   AGE
nginx-gateway-5d4d9b47c4-x8z6l   1/1     Running   0          30s
```

Now, let's configure specific ports for the gateway service:

```bash
# View the nginx-gateway service
kubectl get svc -n nginx-gateway nginx-gateway -o yaml

# Update the service to expose specific nodePort values
kubectl patch svc nginx-gateway -n nginx-gateway --type='json' -p='[
  {"op": "replace", "path": "/spec/ports/0/nodePort", "value": 30080},
  {"op": "replace", "path": "/spec/ports/1/nodePort", "value": 30081}
]'

# Verify the service has been updated
kubectl get svc -n nginx-gateway nginx-gateway
```

The service should now show the specified nodePort values:

```
NAME           TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
nginx-gateway  NodePort   10.96.188.84   <none>        80:30080/TCP,443:30081/TCP   2m
```

## Step 3: Create GatewayClass and Gateway Resources

Now, let's create the GatewayClass and Gateway resources. Save the following YAML to a file named `gateway-resources.yaml`:

```yaml
---
# GatewayClass defines the controller that implements the Gateway API
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
---
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

Apply the configuration:

```bash
kubectl apply -f gateway-resources.yaml

# Verify resources
kubectl get gatewayclass
kubectl get gateway
```

You should see both resources created:

```
NAME                  CONTROLLER                                  ACCEPTED   AGE
nginx-gateway-class   gateway.nginx.org/nginx-gateway-controller  True       15s

NAME            CLASS               ADDRESS         READY   AGE
nginx-gateway   nginx-gateway-class  10.96.188.84   True    15s
```
## Step 4: Create a pod named frontend-app that exposes container on port 8080

## Step 5: Create a svc that expose the frontend-app on port 80 with target port 8080

## Step 6: Expose the Frontend Service

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

Apply the configuration:

```bash
kubectl apply -f frontend-route.yaml

# Verify the HTTPRoute
kubectl get httproute frontend-route
kubectl describe httproute frontend-route
```

You should see the HTTPRoute created and showing as "Accepted":

```
NAME            HOSTNAMES   AGE
frontend-route              30s
```

The `describe` command should show that the HTTPRoute is accepted by the Gateway.

## Step 5: Test the Basic Configuration

To test if your configuration works:

```bash
# Get the node IP (if using minikube)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

# Access the application
curl http://$NODE_IP:30080/

# Or open in a browser:
echo "http://$NODE_IP:30080/"
```

You should see the response from the frontend application.



## Troubleshooting

If you encounter issues:

1. **Check Gateway status**:
   ```bash
   kubectl describe gateway nginx-gateway
   ```
   Look for any errors in the status section.

2. **Check HTTPRoute status**:
   ```bash
   kubectl describe httproute <route-name>
   ```
   Check if the route is accepted by the gateway.

3. **Check NGINX Gateway Fabric logs**:
   ```bash
   kubectl logs -n nginx-gateway deployment/nginx-gateway
   ```
   Look for any errors or issues in the controller logs.

4. **Verify services exist and have endpoints**:
   ```bash
   kubectl get endpoints
   ```
   Make sure your services have endpoints.

## Key Concepts

1. **GatewayClass**: Defines the implementation of the Gateway API (controller)
2. **Gateway**: Defines the actual gateway deployment that processes traffic
3. **HTTPRoute**: Defines how HTTP traffic is routed to backend services
4. **Routing Rules**: 
   - Path-based routing
   - Header-based routing 
   - Traffic splitting/weighting

## Advantages of Gateway API over Traditional Ingress

1. **More expressive routing** - Complex routing patterns are natively supported
2. **Separation of concerns** - Different teams can manage different resources
3. **Standardization** - Consistent behavior across implementations
4. **Extensibility** - Well-designed for custom resources and implementations

By following this guide, you should have a solid understanding of how to use the Gateway API with NGINX Gateway Fabric to implement various routing strategies in Kubernetes.
