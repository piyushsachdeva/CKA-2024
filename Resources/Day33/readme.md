# Day 33: Kubernetes - Learning Ingress

Guide to deploy a hello world application in a pod, create a service for it and expose it to the outside world using Ingress.

## Ingress and Ingress controller

- An **Ingress** is a Kubernetes object that holds HTTP and HTTPS routing rules, for example "send requests for the host `example.com` and the path `/` to the service `hello-world` on port 80".
- An **Ingress controller** is the software that reads these rules and does the actual routing. Kubernetes does not ship with one, so an Ingress object does nothing until you install a controller.
- An **IngressClass** links the two. The `ingressClassName` field of the Ingress says which controller should handle it.

> Note: The video uses the community `ingress-nginx` controller. That project was retired in March 2026 and no longer gets releases or security fixes. The Ingress API itself is not deprecated and is still part of the CKA curriculum, but it is feature-frozen and new work happens in the Gateway API (see the [day47](../day47-GatewayAPI) and [Day48](../Day48-Migrate-Ingress-to-Gateway) folders). The steps below use the NGINX Ingress Controller maintained by F5, which also creates an IngressClass named `nginx`, so the Ingress manifest works the same way as in the video. Any other maintained controller (Traefik, HAProxy, Kong and so on) works too, as long as you set the matching `ingressClassName`.

## Install an Ingress controller

```bash
helm install nginx-ingress oci://ghcr.io/nginx/charts/nginx-ingress \
  --namespace nginx-ingress --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.service.httpPort.nodePort=30080 \
  --set controller.service.httpsPort.nodePort=30443

kubectl get pods,svc -n nginx-ingress
kubectl get ingressclass
```

If you do not have Helm yet, check the [Helm](../Helm) folder for the install steps.

## Build the Docker Image using the Dockerfile

```bash
cd Resources/Day33/Flask
docker build -t <dockerhub-username>/hello-world:v1 .
```

## Push the Docker Image to Docker Hub

```bash
docker login
docker push <dockerhub-username>/hello-world:v1
```

## Create a Deployment

Replace `<dockerhub-username>` in `k8s/deployment.yaml` with your Docker Hub username first.

```bash
kubectl apply -f k8s/deployment.yaml
```

## Create service for the Deployment

```bash
kubectl apply -f k8s/service.yaml
```

## Create Ingress

```bash
kubectl apply -f k8s/ingress.yaml
kubectl get ingress
kubectl describe ingress hello-world
```

## Test

The Ingress rule matches on the host name `example.com`, so the request must carry that host header.

```bash
curl -H "Host: example.com" http://<node-ip>:30080/
```

You should get `Hello, World!` back. Instead of passing the header, you can also add a line `<node-ip> example.com` to `/etc/hosts` and call `http://example.com:30080/`.

## If it does not work

```bash
kubectl get pods -n nginx-ingress                      # is the controller running?
kubectl get ingress hello-world                        # is the CLASS column set to nginx?
kubectl describe ingress hello-world                   # do the backends show pod IPs?
kubectl get endpointslices -l kubernetes.io/service-name=hello-world
kubectl logs -n nginx-ingress -l app.kubernetes.io/name=nginx-ingress
```
