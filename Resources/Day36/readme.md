# Day 36/40 - Monitoring, Logging and Alerting in Kubernetes

Hands-on task details have been provided in [this file](task.md)

### Metrics server

- The metrics server collects CPU and memory usage from the kubelet of every node and makes it available through the metrics API. `kubectl top` and the Horizontal Pod Autoscaler read from this API.
- It keeps only the latest values in memory. It is not a replacement for a full monitoring system such as Prometheus, which stores the history and can raise alerts.
- It is not installed by default on kind and kubeadm clusters. Use the manifest in the [Day16](../Day16) folder, which has the `--kubelet-insecure-tls` flag that these clusters need.

```bash
kubectl apply -f ../Day16/metrics-server.yaml
kubectl get pods -n kube-system -l k8s-app=metrics-server

kubectl top nodes
kubectl top pods -A
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory -l env=prod
kubectl top pod <pod-name> --containers
```

### Application logs

A container writes its logs to stdout and stderr. The container runtime stores them on the node, and `kubectl logs` reads them through the kubelet.

```bash
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>      # pod with more than one container
kubectl logs <pod-name> --all-containers
kubectl logs -f <pod-name>                       # follow
kubectl logs <pod-name> --previous               # logs of the previous, crashed container
kubectl logs <pod-name> --tail=20 --since=10m
kubectl logs -l app=nginx                        # all pods with a label
kubectl logs deploy/<deployment-name>

# search the logs and save the result to a file
kubectl logs <pod-name> | grep -i error > /tmp/errors.txt
```

On the node, the log files are in `/var/log/pods/` and `/var/log/containers/`. When the API server is down and `kubectl` does not work, read them from there or with `crictl`:

```bash
sudo crictl ps -a
sudo crictl logs <container-id>
```

### Events

```bash
kubectl describe pod <pod-name>                  # events of one object, at the bottom
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events -A --field-selector type=Warning
```

Events are kept for one hour by default.

### Cluster component logs

| Component | How it runs on a kubeadm cluster | Where to find the logs |
|---|---|---|
| kube-apiserver, etcd, kube-scheduler, kube-controller-manager | Static pods | `kubectl logs -n kube-system <pod-name>` or `crictl logs` |
| kube-proxy, CoreDNS, CNI plugin | Pods (DaemonSet or Deployment) | `kubectl logs -n kube-system <pod-name>` |
| kubelet | systemd service | `sudo journalctl -u kubelet` |
| containerd | systemd service | `sudo journalctl -u containerd` |

```bash
sudo systemctl status kubelet
sudo journalctl -u kubelet -f
sudo journalctl -u kubelet --since "10 minutes ago" --no-pager | tail -50
```

### Node health

```bash
kubectl get nodes
kubectl describe node <node-name>      # check Conditions, Taints, Allocated resources and Events
```
