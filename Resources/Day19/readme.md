# Day 19/40 - kubernetes configmap and secret

## Check out the video below for Day19 👇

[![Day 19/40 - kubernetes configmap and secret](https://img.youtube.com/vi/Q9fHJLSyd7Q/sddefault.jpg)](https://youtu.be/Q9fHJLSyd7Q)

### What is a config map in Kubernetes?

- When your manifest grows it becomes difficult to manage multiple env vars
- You can take this out of the manifest and store as a config map object in the key-value pair
- Then you can inject that config map into the pod
- You can reuse the same config map into multiple pods

#### Sample command to create a config map

```bash
kubectl create cm <configmapname> --from-literal=color=blue --from-literal=size=large
```
Where `color=blue` and `size=large` are the key-value pairs of the config map. Every key must be unique within a config map.

You can also create a config map from a file or generate the YAML without creating the object:

```bash
kubectl create cm app-config --from-file=app.properties
kubectl create cm app-cm --from-literal=firstname=piyush --dry-run=client -o yaml > cm.yaml
kubectl describe cm app-cm
```


#### Secrets

- A secret works like a config map but is meant for sensitive data such as passwords, tokens and keys.
- The values in a secret are base64 **encoded**, not encrypted. Anyone who can read the secret can decode it. To protect secrets you restrict access with RBAC and enable encryption at rest for etcd.

```bash
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password='S3cret!'
kubectl get secret db-secret -o yaml
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d
```

Follow the doc: https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data

### Sample YAMLs used in the demo

```yaml
apiVersion: v1
data:
  firstname: piyush
  lastname: sachdeva
kind: ConfigMap
metadata:
  name: app-cm
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app.kubernetes.io/name: MyApp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    env:
    - name: FIRSTNAME
      valueFrom:
        configMapKeyRef:
          name: app-cm
          key: firstname
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
```

The same pattern works for a secret, with `secretKeyRef` in place of `configMapKeyRef`. To load every key of a config map or a secret as environment variables in one go, use `envFrom`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: envfrom-pod
spec:
  containers:
  - name: app
    image: busybox:1.28
    command: ['sh', '-c', 'env && sleep 3600']
    envFrom:
    - configMapRef:
        name: app-cm
    - secretRef:
        name: db-secret
```

You can also mount a config map or a secret as a volume. Each key becomes a file and the value becomes the content of that file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: app
    image: busybox:1.28
    command: ['sh', '-c', 'ls /etc/config /etc/secret && sleep 3600']
    volumeMounts:
    - name: config
      mountPath: /etc/config
    - name: secret
      mountPath: /etc/secret
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: app-cm
  - name: secret
    secret:
      secretName: db-secret
```

> Note: Environment variables are read once when the container starts. If you change the config map, restart the pods to pick up the new values (`kubectl rollout restart deployment <name>`). Values mounted as a volume are refreshed by the kubelet after a short delay.
