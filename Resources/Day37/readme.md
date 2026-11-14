# Day 37/40 - Troubleshoot application failure in Kubernetes

Check out the [task.md](task.md) file for hands-on practice.

### Where to start

Follow the request from the outside to the inside: Service, then Pod, then the container. Most application problems are found with these four commands:

```bash
kubectl get pods -o wide
kubectl describe pod <pod-name>          # read the Events at the bottom
kubectl logs <pod-name> [--previous]
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Pod status and what it usually means

| Status | Usual cause | What to check |
|---|---|---|
| `Pending` | No node fits: not enough CPU or memory, a taint without a toleration, a node selector or affinity that matches nothing, or a PVC that is not bound | `kubectl describe pod`, `kubectl get pvc` |
| `ImagePullBackOff` / `ErrImagePull` | Wrong image name or tag, or a private registry without an image pull secret | The image name in `kubectl describe pod` |
| `CrashLoopBackOff` | The container starts and exits again: wrong command or args, missing env variable or config, failing liveness probe | `kubectl logs --previous` |
| `CreateContainerConfigError` | The pod refers to a ConfigMap or Secret (or a key in it) that does not exist | `kubectl describe pod` |
| `OOMKilled` | The container used more memory than its limit | `kubectl describe pod`, raise the limit |
| `Running` but `0/1` ready | The readiness probe is failing | Probe path and port |
| `Init:0/1` | An init container has not finished | `kubectl logs <pod> -c <init-container>` |

### Service checks

```bash
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpointslices -l kubernetes.io/service-name=<service-name>
kubectl get pods --show-labels
```

- **No endpoints**: the `selector` of the Service does not match the labels of the pods, or the pods are not ready.
- **Endpoints exist but the connection fails**: the `targetPort` of the Service is not the port that the container listens on.
- **Works inside the cluster but not from outside**: check the Service type and the `nodePort`.
- **Works by IP but not by name**: DNS problem. Check the service name and namespace that the application uses, and CoreDNS (Day 31).
- **Connection times out between pods**: check for a network policy (`kubectl get netpol -A`).

Test from inside the cluster with a temporary pod:

```bash
kubectl run tmp --rm -it --image=busybox:1.28 --restart=Never -- wget -qO- -T 3 http://<service-name>:<port>
kubectl run tmp --rm -it --image=busybox:1.28 --restart=Never -- nslookup <service-name>
```

### Fixing things

```bash
kubectl edit deployment <name>
kubectl set image deployment/<name> <container>=<image>
kubectl set env deployment/<name> KEY=value
kubectl rollout restart deployment <name>
kubectl rollout undo deployment <name>
```

Most fields of a running pod cannot be edited. For a pod that is not managed by a controller, save the YAML, fix it and recreate the pod:

```bash
kubectl get pod <pod-name> -o yaml > pod.yaml
kubectl replace --force -f pod.yaml
```

To look inside a running container, or to debug a pod whose image has no shell:

```bash
kubectl exec -it <pod-name> -- sh
kubectl debug -it <pod-name> --image=busybox:1.28 --target=<container-name>
```
