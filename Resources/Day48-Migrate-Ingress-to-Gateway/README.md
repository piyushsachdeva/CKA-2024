# Solution: Migrating from Ingress to Gateway API

This document provides a step-by-step solution for migrating an existing Kubernetes Ingress resource to the Gateway API.

## Prerequisites

- A Kubernetes cluster(1.24+) (this guide works with minikube, kind, or playground such as [kodekloud](https://kode.wiki/4d24Q9Z) or cloud providers)
- kubectl installed and configured
- Basic understanding of Kubernetes concepts such as pod, deployment, Ingress, services etc

## Step 1: Deploy the Sample Web Application and Services

Let's first create the sample web application and services that our Ingress will route to:

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
        image: nginx:latest
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

Controller

```bash
wget https://get.helm.sh/helm-v3.10.3-linux-amd64.tar.gz
tar -zxf helm-v3.10.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin

helm install ingress-nginx \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=30082 \
    --set controller.service.nodePorts.https=30443 \
    --repo https://kubernetes.github.io/ingress-nginx \
    ingress-nginx

```


Now let's create the original Ingress resource that we'll later migrate to Gateway API:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: web-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
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
NAME   CLASS    HOSTS                    ADDRESS     PORTS     AGE
web    <none>   gateway.web.k8s.local    10.0.0.1    80, 443   30s
```

## Step 4: Test the Ingress Configuration

Let's make sure the Ingress is working before we migrate:

```bash
# Add an entry to /etc/hosts for local testing
echo "$(kubectl get ingress web -n web-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}') gateway.web.k8s.local" | sudo tee -a /etc/hosts

# Test HTTP access
curl -k http://gateway.web.k8s.local/
curl -k https://gateway.web.k8s.local/
```

## Step 5: Inspect the Existing Ingress Resource

Now, let's inspect the Ingress resource to understand its configuration before migrating:

```bash
kubectl get ingress web -n web-app -o yaml
```
                                                                                                    
## Step 6: Install Gateway API Resources

First, we need to install the Gateway API CRDs (Custom Resource Definitions):

```bash
# Install Gateway API resources
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.5.1" | kubectl apply -f -

# Verify installation
kubectl get crd | grep gateway
```

Expected output should include CRDs like `gatewayclasses.gateway.networking.k8s.io`, `gateways.gateway.networking.k8s.io`, and `httproutes.gateway.networking.k8s.io`.

## Step 7: Configure NGINX Gateway Fabric

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

## Step 8: Create GatewayClass and Gateway Resources

Now, let's create the GatewayClass and Gateway resources. Save the following YAML to a file named `gateway-resources.yaml`:

```bash
cat <<EOF | kubectl apply -f -
# GatewayClass defines the controller that implements the Gateway API
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
EOF                                                                                               
```
Now, let's migrate to the Gateway API by first creating the Gateway resource:

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
```

Expected output:
```
NAME          CLASS   ADDRESS        PROGRAMMED   AGE
web-gateway   nginx   10.0.0.1       True         30s
```

## Step 9: Create the HTTPRoute Resource


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
    sectionName: http
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
```

### Create HTTPRoute for HTTPS

```bash

cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route-https
  namespace: web-app
spec:
  parentRefs:
  - name: nginx-gateway
    kind: Gateway
    namespace: nginx-gateway
    sectionName: https
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

# Verify the HTTPRoute resources
kubectl get httproute -n web-app

```

Expected output:
```
NAME        HOSTNAMES                  AGE
web-route   ["gateway.web.k8s.local"]  30s
web-route-https   ["gateway.web.k8s.local"]  10s
```



## Step 10: Verify the Gateway API Configuration

Let's verify that our Gateway API resources are properly configured:

```bash
# Check the Gateway status
kubectl describe gateway nginx-gateway -n web-app

# Check the HTTPRoute status
kubectl describe httproute web-route -n web-app

# Check if the HTTPRoute is properly bound to the Gateway
kubectl get httproute web-route -n web-app -o jsonpath='{.status.parents[0].conditions[?(@.type=="Accepted")].status}'
kubectl get httproute web-route-https -n web-app -o jsonpath='{.status.parents[0].conditions[?(@.type=="Accepted")].status}'

```

The output for the last command should be "True" if the HTTPRoute is properly accepted by the Gateway.


If you are facing error with the listener, make sure that secret was created in the same namespace as gateway, if not, create the below reference grant

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
## Step 11: Test the Gateway API Configuration

Now, test that the application is accessible through the new Gateway API:

```bash
# Test the / endpoint
curl -v -H "Host: gateway.web.k8s.local" http://$NODE_IP:30080/

# Add the entry in /etc/hosts
# ${NODE_IP}   gateway.web.k8s.local

# Test the / endpoint
curl -v -k https://gateway.web.k8s.local:30081/
```

You should see the expected responses from both services.


## Step 12: Remove the Old Ingress Resource (After Verification)

Once you've verified that the Gateway API is working correctly, you can remove the old Ingress resource:

```bash
kubectl delete ingress web -n web-app
```

## Troubleshooting

### Gateway Controller Issues

If your Gateway isn't getting programmed:

```bash
# Check Gateway controller logs
kubectl logs -n nginx-gateway deployment/nginx-gateway

# Check Gateway status for errors
kubectl describe gateway web-gateway -n web-app
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
# Verify the secret exists
kubectl get secret web-tls-secret -n web-app

# Test with specific TLS options
curl -k -v https://gateway.web.k8s.local/
```
