# Day 18/40 - Health Probes in Kubernetes

## Check out the video below for Day18 👇

[![Day 18/40 - Health Probes in kubernetes](https://img.youtube.com/vi/x2e6pIBLKzw/sddefault.jpg)](https://youtu.be/x2e6pIBLKzw)


### What are probes?
- To investigate or monitor something and to take necessary actions

### What are health probes in Kubernetes?
- Health probes monitor your Kubernetes applications and take necessary actions to recover from failure
- To ensure your application is highly available and self-healing

### Type of health probes in Kubernetes
- Readiness (checks that the application is ready to receive traffic. If it fails, the pod is removed from the Service endpoints. The container is not restarted)
- Liveness (restarts the container if the health check fails)
- Startup (for slow-starting applications. Liveness and readiness checks start only after the startup probe has passed)

### Types of health checks they perform?
- HTTP (`httpGet`), TCP (`tcpSocket`), command (`exec`) and gRPC (`grpc`)

### Common probe settings
- `initialDelaySeconds`: wait this long after the container starts before the first check (default 0)
- `periodSeconds`: how often to run the check (default 10)
- `timeoutSeconds`: how long to wait for a response (default 1)
- `failureThreshold`: how many failures in a row before the probe is treated as failed (default 3)
- `successThreshold`: how many successes in a row before the probe is treated as passed again (default 1)

### Health probes

![image](https://github.com/user-attachments/assets/95f34a79-4956-4555-b33d-aeddf86653c5)

### Sample YAML

#### liveness-http and readiness-http
``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello
spec:
  containers:
  - name: liveness
    image: registry.k8s.io/e2e-test-images/agnhost:2.40
    args:
    - liveness
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 3
      periodSeconds: 3
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
```

#### liveness command

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: registry.k8s.io/busybox:1.27.2
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat 
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

#### liveness-tcp

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tcp-pod
  labels:
    app: tcp-pod
spec:
  containers:
  - name: goproxy
    image: registry.k8s.io/goproxy:0.1
    ports:
    - containerPort: 8080
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
```

> Note: The container listens on port 8080. If you change the probe port to one where nothing is listening, for example 3000, the probe fails and you can watch the kubelet restart the container (`kubectl describe pod tcp-pod`).

#### startup probe

The startup probe below gives the application up to 30 x 10 = 300 seconds to start. The liveness probe takes over only after the startup probe has succeeded once.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-demo
spec:
  containers:
  - name: app
    image: registry.k8s.io/e2e-test-images/agnhost:2.40
    args:
    - liveness
    startupProbe:
      httpGet:
        path: /healthz
        port: 8080
      failureThreshold: 30
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      periodSeconds: 10
```
