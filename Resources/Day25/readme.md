
# Day 25/40 - Kubernetes Service Account - RBAC Continued

## Check out the video below for Day25 👇

[![Day 25/40 - Kubernetes Service Account - RBAC Continued ](https://img.youtube.com/vi/k2iCq7IlMKM/sddefault.jpg)](https://youtu.be/k2iCq7IlMKM)

### Service account in Kubernetes

![image](https://github.com/user-attachments/assets/7fec4f33-1643-4533-be5a-10a6b305d14c)


#### What is a service account in Kubernetes

There are multiple types of accounts in Kubernetes that interact with the cluster. These could be user accounts used by Kubernetes Admins, developers, operators, etc., and service accounts primarily used by other applications/bots or Kubernetes components to interact with other services.

- To create a service account
```
kubectl create sa build-sa
kubectl get sa
```

- Then you can add a role and a role binding to grant access
```
kubectl create role build-role --verb=get,list,watch --resource=pods
kubectl create rolebinding build-rb --role=build-role --serviceaccount=default:build-sa
kubectl auth can-i list pods --as=system:serviceaccount:default:build-sa
```

- To use the service account in a pod, set `serviceAccountName` in the pod spec
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: build-pod
spec:
  serviceAccountName: build-sa
  containers:
  - name: app
    image: nginx
```

>Note: Kubernetes creates a service account named `default` in every namespace. A pod that does not set `serviceAccountName` runs with the `default` service account of its namespace.

#### Service account tokens

- Since Kubernetes 1.24, a Secret with a long-lived token is no longer created automatically when you create a service account.
- A pod gets a short-lived token that the kubelet rotates on its own. It is mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`.
- To get a token for use outside a pod (for example in a CI pipeline), request one:
```
kubectl create token build-sa
kubectl create token build-sa --duration=1h
```
- If a pod does not need to talk to the API server, switch off the token mount with `automountServiceAccountToken: false` in the pod spec or on the service account.
