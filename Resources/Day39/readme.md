# Day 39/40 - Troubleshooting Worker Nodes Failures in Kubernetes

## Check out the video below for Day39 👇

[![Day 39/40 - Troubleshooting Worker Nodes Failures in Kubernetes](https://img.youtube.com/vi/U6PRwv7dJ-U/sddefault.jpg)](https://youtu.be/U6PRwv7dJ-U)

## Task for the video
Hands-on task details have been provided in [this file](task.md)

## Node is NotReady: what to check

Start from the control plane node:

```bash
kubectl get nodes
kubectl describe node <node-name>      # read Conditions and Events
```

Then SSH into the node that has the problem and check in this order:

1. **Is the kubelet running?**

```bash
sudo systemctl status kubelet
sudo journalctl -u kubelet --no-pager | tail -50
```

2. **If it is stopped, start it and make sure it starts again after a reboot.**

```bash
sudo systemctl enable --now kubelet
```

3. **If it keeps crashing, the logs tell you why.** The usual causes are:

| Message in the kubelet logs | Where to fix it |
|---|---|
| `failed to load kubelet config file` or an error about a field in the config | `/var/lib/kubelet/config.yaml` |
| `unable to load client CA file` | `clientCAFile` in `/var/lib/kubelet/config.yaml`. The right value is `/etc/kubernetes/pki/ca.crt` |
| `connection refused` or `no such host` for the API server | `server:` in `/etc/kubernetes/kubelet.conf`. It must be `https://<control-plane-ip>:6443` |
| Wrong binary path or wrong flags | `/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf` and `/var/lib/kubelet/kubeadm-flags.env` |
| `container runtime is not running` | `sudo systemctl status containerd`, then `sudo systemctl enable --now containerd` |
| `cni plugin not initialized` | The CNI plugin pods (`kubectl get pods -A -o wide`), `/etc/cni/net.d` and `/opt/cni/bin` on the node |

4. **After every fix, reload and restart.**

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

5. **Check the basics of the machine.**

```bash
df -h          # disk full
free -m        # out of memory
swapon --show  # swap must be off unless the kubelet is configured for it
```

## Node maintenance

```bash
kubectl cordon <node-name>       # mark the node unschedulable. Running pods stay
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data   # cordon + evict the pods
kubectl uncordon <node-name>     # allow scheduling again
```

After `uncordon`, the pods that were evicted do not move back on their own. Only new pods are scheduled on the node.

## Network troubleshooting

When the nodes are `Ready` but an application cannot be reached, check the network path step by step:

```bash
# 1. pod to pod, by IP
kubectl get pods -o wide
kubectl exec <pod-a> -- wget -qO- -T 3 http://<pod-b-ip>:<port>

# 2. pod to service, by ClusterIP and then by name
kubectl get svc
kubectl exec <pod-a> -- wget -qO- -T 3 http://<cluster-ip>:<port>
kubectl exec <pod-a> -- nslookup <service-name>

# 3. the cluster components that provide networking
kubectl get pods -n kube-system -o wide | grep -E "kube-proxy|coredns"
kubectl get pods -A -o wide | grep -E "calico|cilium|flannel"
kubectl logs -n kube-system -l k8s-app=kube-proxy
```

- **Pod to pod by IP fails**: CNI plugin problem (its pods are not running on that node) or a network policy.
- **Pod IP works but the ClusterIP does not**: check that the Service has endpoints, and check kube-proxy on that node.
- **ClusterIP works but the name does not**: CoreDNS problem, see [Day31](../Day31).
- **NodePort does not answer from outside**: firewall or security group on the node, or the wrong node IP.
