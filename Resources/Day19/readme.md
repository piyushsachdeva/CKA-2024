# Day 19/40 - kubernetes configmap and secret

## Check out the video below for Day19 👇

[![Day 19/40 - kubernetes configmap and secret](https://img.youtube.com/vi/Q9fHJLSyd7Q/sddefault.jpg)](https://youtu.be/Q9fHJLSyd7Q)

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
