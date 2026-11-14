# Day 9/40 - Kubernetes Services Explained - ClusterIP vs NodePort vs Loadbalancer vs External ☸️


## Check out the video below for Day9 👇

[![Day9/40 - Kubernetes Services Explained - ClusterIP vs NodePort vs Loadbalancer vs External](https://img.youtube.com/vi/tHAQWLKMTB0/sddefault.jpg)](https://youtu.be/tHAQWLKMTB0)


### Pre-requisite for Kind cluster
A kind node is a container, so a NodePort on the node is not reachable from your laptop unless you map the port when you create the cluster. Use the below config to create a new Kind cluster

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30001
    hostPort: 30001
- role: worker
- role: worker
```

### Command to create the new cluster

```bash
kind create cluster --config kind.yaml --name cka-cluster
```

### What is Service in Kubernetes

Pods are short-lived and their IP addresses change every time they are recreated. A Service gives a group of pods one stable IP address and DNS name, and load balances the traffic between them. Applications inside the cluster use a Service to talk to each other, and a Service is also how you expose an application outside the cluster.

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/e768b073-dd7b-478a-bbea-ad6acae18051)

There are 4 types of Services:
- ClusterIP (the default type, for access from inside the cluster only)
- NodePort (opens the same port on every node so that the application can be reached from outside the cluster on `<NodeIP>:<nodePort>`)
- LoadBalancer (asks the cloud provider for an external load balancer, so the application gets its own external IP address)
- ExternalName (maps the Service name to an external DNS name by returning a CNAME record. The video title calls this "External")

### Ports in a Service
- `port`: the port on which the Service itself listens
- `targetPort`: the container port to which the Service forwards the traffic. If you leave it out, it is the same as `port`
- `nodePort`: the port opened on every node for NodePort and LoadBalancer Services. The default range is 30000-32767

### ClusterIP

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/3817a5e7-5208-41c8-9dee-d4c052038151)

#### Sample YAML for ClusterIP

```yaml
apiVersion: v1
kind: Service
metadata:
  name: cluster-svc
  labels:
    env: demo
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    env: demo
```


### NodePort

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/8aa9c482-be3a-450a-95b7-0a0c0e80403e)

#### Sample YAML for Nodeport

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodeport-svc
  labels:
    env: demo
spec:
  type: NodePort
  ports:
  - nodePort: 30001
    port: 80
    targetPort: 80
  selector:
    env: demo
```


### LoadBalancer
- In a managed cloud environment such as GKE, AKS or EKS, Kubernetes creates a load balancer in your cloud account, and that load balancer sends the traffic to the Service.
- On a local cluster (kind, kubeadm on VMs) there is no cloud provider to create the load balancer, so the `EXTERNAL-IP` of the Service stays in `<pending>`. A LoadBalancer Service also gets a ClusterIP and a NodePort, so you can still reach the application on the NodePort. To get a real external IP on a local cluster you need an add-on such as MetalLB or `cloud-provider-kind`.

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/8f5acc88-4394-47e9-a3c5-041d396166d0)

#### Sample YAML for Loadbalancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lb-svc
  labels:
    env: demo
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    env: demo
```

#### Sample YAML for external name

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.api.example.com
```

### Useful commands

```bash
# expose a deployment imperatively
kubectl expose deployment nginx-deploy --name=cluster-svc --port=80 --target-port=80
kubectl expose deployment nginx-deploy --name=nodeport-svc --type=NodePort --port=80

# check that the Service has found its pods
kubectl get svc
kubectl describe svc cluster-svc
kubectl get endpointslices -l kubernetes.io/service-name=cluster-svc
```

> Note: If a Service has no endpoints, its `selector` does not match the labels of any running pod. This is the most common Service problem in the exam. Older material uses `kubectl get endpoints` for this check. The Endpoints API is deprecated since Kubernetes 1.33 in favour of EndpointSlices, so the command still works but prints a deprecation warning.
