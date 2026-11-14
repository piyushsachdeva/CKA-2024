# Day 11/40 - Multi Container Pod Kubernetes - Sidecar vs Init Container

## Check out the video below for Day11 👇

[![Day11/40 - Multi Container Pod Kubernetes - Sidecar vs Init Container](https://img.youtube.com/vi/yRiFq1ykBxc/sddefault.jpg)](https://youtu.be/yRiFq1ykBxc)


## Sample YAML used in the demo

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
      value: "Piyush"
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c'] #command to run
    args: ['until nslookup myservice.default.svc.cluster.local; do echo waiting for myservice; sleep 2; done']
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c']
    args: ['until nslookup mydb.default.svc.cluster.local; do echo waiting for mydb; sleep 2; done']
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
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c'] # command to run
    args: # arguments to the command
      - > # multi-line string
        until nslookup myservice.default.svc.cluster.local; do
         echo waiting for myservice;
         sleep 2;
        done;
```

> Note: The init containers above wait until the services `myservice` and `mydb` exist. The pod stays in `Init:0/2` until you create them:

```bash
kubectl create deployment nginx-deploy --image=nginx
kubectl expose deployment nginx-deploy --name=myservice --port=80
kubectl expose deployment nginx-deploy --name=mydb --port=80
kubectl get pod myapp-pod -w
kubectl logs myapp-pod -c init-myservice
```

## Init container vs sidecar container

- **Init containers** run one after the other and each one must finish successfully before the next one starts. The app containers start only after all the init containers are done.
- **Sidecar containers** run next to the main app container for the whole life of the pod, for example a log shipper or a proxy.

Since Kubernetes 1.29 there is built-in support for sidecars, and it is stable since 1.33. You define a sidecar as an init container with `restartPolicy: Always`. Kubernetes starts it before the app containers, keeps it running, and stops it after the app containers have exited. This was not available when the video was recorded, where a sidecar is simply a second entry under `containers`. Both ways work, and exam tasks can ask for either.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-sidecar
spec:
  volumes:
  - name: logs
    emptyDir: {}
  initContainers:
  - name: log-shipper              # sidecar: an init container that keeps running
    image: busybox:1.28
    restartPolicy: Always
    command: ['sh', '-c', 'tail -F /var/log/app.log']
    volumeMounts:
    - name: logs
      mountPath: /var/log
  containers:
  - name: app
    image: busybox:1.28
    command: ['sh', '-c', 'while true; do date >> /var/log/app.log; sleep 5; done']
    volumeMounts:
    - name: logs
      mountPath: /var/log
```

```bash
kubectl logs app-with-sidecar -c log-shipper
```
