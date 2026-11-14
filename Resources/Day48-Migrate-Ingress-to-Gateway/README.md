# Day 48 - Solution: Migrating from Ingress to Gateway API

This document provides a step-by-step solution for migrating an existing Kubernetes Ingress resource to the Gateway API. The assignment is in [task.md](task.md).

> Note: The video uses the community `ingress-nginx` controller, Helm 3.10 and NGINX Gateway Fabric 1.6. The `ingress-nginx` project was retired in March 2026, which is exactly the situation where you do a migration like this one. The steps below use the NGINX Ingress Controller maintained by F5 for the "before" state and NGINX Gateway Fabric 2.8.1 for the "after" state. Read the [day47](../day47-GatewayAPI) notes first, they explain the Gateway API objects and how NGINX Gateway Fabric 2.x works.

## How an Ingress maps to the Gateway API

| Ingress | Gateway API |
|---|---|
| `ingressClassName` | `gatewayClassName` on the Gateway |
| `spec.tls` (hosts and secret) | A listener on the Gateway with `protocol: HTTPS` and `tls.certificateRefs` |
| `spec.rules[].host` | `hostnames` on the HTTPRoute (and optionally `hostname` on the listener) |
| `spec.rules[].http.paths[]` with `pathType: Prefix` | `rules[].matches[].path` with `type: PathPrefix` |
| `backend.service.name` and `port.number` | `backendRefs[].name` and `port` |
| Controller-specific annotations (rewrite, redirect and so on) | Filters on the HTTPRoute, for example `URLRewrite` and `RequestRedirect` |

## Prerequisites

- A Kubernetes cluster (the kubeadm cluster from Day 27, minikube, kind, or a playground such as [Killercoda](https://killercoda.com/playgrounds/scenario/kubernetes))
- kubectl installed and configured
- Basic understanding of Kubernetes concepts such as pod, deployment, Ingress, services etc

> Note: If you are using kind, create the cluster with `extraPortMappings` for the ports 30080, 30081, 30082 and 30443 (see the [Day09](../Day09) readme).

## Step 1: Deploy the Sample Web Application and Service

Let's first create the sample web application and the service that our Ingress will route to:

```bash
# Create a namespace for our web application
kubectl create namespace web-app

# Create the web-service deployment and service
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-service
  namespace: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-service
  template:
    metadata:
      labels:
        app: web-service
    spec:
      containers:
      - name: web
        image: nginx:stable-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: web-config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: web-config
        configMap:
          name: web-content
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: web-app
spec:
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: web-service
EOF

# Create ConfigMap with sample content
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-content
  namespace: web-app
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <body>
      <h1>Web Application Content</h1>
      <p>This is the web front-end service.</p>
    </body>
    </html>
EOF
```

## Step 2: Create TLS Secret for HTTPS

Before setting up the Ingress, let's create a self-signed certificate for TLS:

```bash
# Generate a self-signed certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=gateway.web.k8s.local" \
  -addext "subjectAltName = DNS:gateway.web.k8s.local"

# Create the TLS secret in Kubernetes
kubectl create secret tls web-tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  --namespace=web-app

# Verify the secret was created
kubectl get secret web-tls-secret -n web-app
```

## Step 3: Create the Ingress Controller and Ingress Resource

Install Helm, if you do not have it already:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
```

Install the Ingress controller:

```bash
helm install nginx-ingress oci://ghcr.io/nginx/charts/nginx-ingress \
    --namespace nginx-ingress --create-namespace \
    --set controller.service.type=NodePort \
    --set controller.service.httpPort.nodePort=30082 \
    --set controller.service.httpsPort.nodePort=30443

kubectl get pods -n nginx-ingress
kubectl get ingressclass
```

Now let's create the original Ingress resource that we'll later migrate to Gateway API:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: web-app
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: web-tls-secret
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF

# Verify the Ingress resource
kubectl get ingress -n web-app
```

Expected output:
```
NAME   CLASS   HOSTS                   ADDRESS   PORTS     AGE
web    nginx   gateway.web.k8s.local             80, 443   30s
```

## Step 4: Test the Ingress Configuration

Let's make sure the Ingress is working before we migrate:

```bash
# Get the internal IP of the first node
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Add an entry to /etc/hosts for local testing
echo "$NODE_IP gateway.web.k8s.local" | sudo tee -a /etc/hosts

# Test HTTP and HTTPS access through the Ingress controller
curl http://gateway.web.k8s.local:30082/
curl -k https://gateway.web.k8s.local:30443/
```

Both commands should return the "Web Application Content" page. The `-k` flag is needed because the certificate is self-signed.

## Step 5: Inspect the Existing Ingress Resource

Now, let's inspect the Ingress resource to understand its configuration before migrating. Note down the class, the host, the TLS secret, the paths and the backend service. These are the values that you carry over to the Gateway and the HTTPRoute.

```bash
kubectl get ingress web -n web-app -o yaml
```

## Step 6: Install Gateway API Resources

First, we need to install the Gateway API CRDs (Custom Resource Definitions):

```bash
# Install Gateway API resources
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.8.1" | kubectl apply -f -

# Verify installation
kubectl get crd | grep gateway.networking.k8s.io
```

Expected output should include CRDs like `gatewayclasses.gateway.networking.k8s.io`, `gateways.gateway.networking.k8s.io`, and `httproutes.gateway.networking.k8s.io`.

## Step 7: Install NGINX Gateway Fabric

Next, we'll install NGINX Gateway Fabric as our Gateway API controller:

```bash
# Deploy NGINX Gateway Fabric CRDs
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.8.1/deploy/crds.yaml

# Deploy NGINX Gateway Fabric
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.8.1/deploy/nodeport/deploy.yaml

# Verify the deployment
kubectl get pods -n nginx-gateway
kubectl get gatewayclass
```

The install creates the GatewayClass `nginx` for you, so there is no need to create one.

Now, let's set fixed NodePort values for the Gateway listeners, port 80 on 30080 and port 443 on 30081:

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

## Step 8: Allow the Gateway to read the TLS Secret

We will create the Gateway in the `nginx-gateway` namespace, but the TLS secret is in the `web-app` namespace. The Gateway API does not allow a reference across namespaces unless the owner of the target namespace agrees to it with a ReferenceGrant. Without it, the HTTPS listener reports the error `RefNotPermitted`.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-gateway-to-web-app-secrets
  namespace: web-app # This ReferenceGrant must be in the namespace of the Secret
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: Gateway
    namespace: nginx-gateway # This specifies which namespace is allowed to reference
  to:
  - group: "" # Core API group for Secrets
    kind: Secret
    name: web-tls-secret # Optionally, restrict to a specific secret name (or omit name for all secrets)
EOF
```

If you create the Gateway in the same namespace as the secret, you do not need a ReferenceGrant.

## Step 9: Create the Gateway Resource

Now, let's migrate to the Gateway API by first creating the Gateway resource. The `tls` section of the Ingress becomes the HTTPS listener here:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: nginx-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx # Use the gateway class that matches your controller
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: gateway.web.k8s.local
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: web-tls-secret
        namespace: web-app
    allowedRoutes:
      namespaces:
        from: All
  - name: http
    port: 80
    protocol: HTTP
    hostname: gateway.web.k8s.local
    allowedRoutes:
      namespaces:
        from: All
EOF

# Verify the Gateway resource
kubectl get gateway -n nginx-gateway
kubectl get svc -n nginx-gateway
```

Expected output:
```
NAME            CLASS   ADDRESS        PROGRAMMED   AGE
nginx-gateway   nginx   10.96.188.84   True         30s

NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
nginx-gateway         ClusterIP   10.96.12.200   <none>        443/TCP                      2m
nginx-gateway-nginx   NodePort    10.96.188.84   <none>        80:30080/TCP,443:30081/TCP   30s
```

## Step 10: Create the HTTPRoute Resource

The `rules` section of the Ingress becomes the HTTPRoute. A single HTTPRoute can attach to both the listeners of the Gateway. When `parentRefs` has no `sectionName`, the route attaches to every listener that allows it.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: web-app
spec:
  parentRefs:
  - name: nginx-gateway
    kind: Gateway
    namespace: nginx-gateway
  hostnames:
  - gateway.web.k8s.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-service
      port: 80
EOF

# Verify the HTTPRoute resource
kubectl get httproute -n web-app
```

Expected output:
```
NAME        HOSTNAMES                   AGE
web-route   ["gateway.web.k8s.local"]   30s
```

> Note: The video creates two HTTPRoutes, `web-route` with `sectionName: http` and `web-route-https` with `sectionName: https`. That works as well. You need separate routes per listener only when HTTP and HTTPS should behave differently, for example when HTTP should redirect to HTTPS.

## Step 11: Verify the Gateway API Configuration

Let's verify that our Gateway API resources are properly configured:

```bash
# Check the Gateway status. Both listeners should show Programmed: True
kubectl describe gateway nginx-gateway -n nginx-gateway

# Check the HTTPRoute status
kubectl describe httproute web-route -n web-app

# Check if the HTTPRoute is accepted by the Gateway
kubectl get httproute web-route -n web-app -o jsonpath='{.status.parents[0].conditions[?(@.type=="Accepted")].status}'
```

The output for the last command should be "True" if the HTTPRoute is properly accepted by the Gateway.

## Step 12: Test the Gateway API Configuration

Now, test that the application is accessible through the new Gateway API. The `/etc/hosts` entry from Step 4 is still in place.

```bash
# Test the / endpoint over HTTP
curl http://gateway.web.k8s.local:30080/

# Test the / endpoint over HTTPS
curl -k https://gateway.web.k8s.local:30081/
```

You should see the same "Web Application Content" page as you got through the Ingress in Step 4.


## Step 13: Remove the Old Ingress Resource (After Verification)

Once you've verified that the Gateway API is working correctly, you can remove the old Ingress resource:

```bash
kubectl delete ingress web -n web-app
```

If nothing else uses the Ingress controller, remove it as well:

```bash
helm uninstall nginx-ingress -n nginx-ingress
```

## The ingress2gateway tool

For a real migration with many Ingress objects, the Kubernetes project has a tool called [ingress2gateway](https://github.com/kubernetes-sigs/ingress2gateway) that reads your Ingress objects and prints the matching Gateway API manifests. It is a good starting point, but check its output by hand, mainly for the annotations. In the exam you write the Gateway and the HTTPRoute yourself, as done above.

## Troubleshooting

### Gateway Controller Issues

If your Gateway isn't getting programmed:

```bash
# Check Gateway controller logs
kubectl logs -n nginx-gateway deployment/nginx-gateway

# Check Gateway status for errors
kubectl describe gateway nginx-gateway -n nginx-gateway
```

### HTTPRoute Issues

If your routes aren't working:

```bash
# Check HTTPRoute status
kubectl describe httproute web-route -n web-app

# Check if services are reachable directly
kubectl port-forward svc/web-service -n web-app 8080:80
# In another terminal
curl localhost:8080
```

### TLS Issues

If you're experiencing TLS issues:

```bash
# Verify the secret exists and is of type kubernetes.io/tls
kubectl get secret web-tls-secret -n web-app

# Verify the ReferenceGrant exists
kubectl get referencegrant -n web-app

# Test with specific TLS options
curl -k -v https://gateway.web.k8s.local:30081/
```
