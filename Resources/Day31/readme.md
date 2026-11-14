# Day 31/40 - Understanding CoreDNS In Kubernetes

## Check out the video below for Day31 👇

[![Day 31/40 - Understanding CoreDNS In Kubernetes ](https://img.youtube.com/vi/VcWpZoRAQXE/sddefault.jpg)](https://youtu.be/VcWpZoRAQXE)

### Key points from the video

- CoreDNS is the DNS server of the cluster. It runs as a Deployment named `coredns` in the `kube-system` namespace and is exposed through a Service named `kube-dns`.
- The kubelet writes the ClusterIP of the `kube-dns` service into `/etc/resolv.conf` of every pod, so every pod uses CoreDNS for name resolution.
- CoreDNS watches the API server and creates DNS records for Services and Pods on its own.

### DNS names in a cluster

| Object | DNS name |
|---|---|
| Service | `<service>.<namespace>.svc.cluster.local` |
| Pod | `<pod-ip-with-dashes>.<namespace>.pod.cluster.local`, for example `10-244-1-5.default.pod.cluster.local` |
| Pod of a StatefulSet with a headless service | `<pod-name>.<service>.<namespace>.svc.cluster.local` |

Inside the same namespace the short name `<service>` is enough. From another namespace use `<service>.<namespace>`. This works because of the `search` line in the pod's `/etc/resolv.conf`.

### Commands used in the video

```bash
kubectl get deploy,svc,pods -n kube-system -l k8s-app=kube-dns
kubectl get endpointslices -n kube-system -l k8s-app=kube-dns

# the CoreDNS configuration (Corefile)
kubectl get configmap coredns -n kube-system -o yaml

# what a pod uses for DNS
kubectl run test --image=busybox:1.28 --restart=Never -- sleep 3600
kubectl exec test -- cat /etc/resolv.conf
kubectl exec test -- nslookup kubernetes.default

# where the kubelet gets the DNS server IP and the cluster domain from
sudo grep -A2 clusterDNS /var/lib/kubelet/config.yaml
```

### Troubleshooting DNS

1. Check that the CoreDNS pods are `Running`: `kubectl get pods -n kube-system -l k8s-app=kube-dns`
2. Check their logs: `kubectl logs -n kube-system -l k8s-app=kube-dns`
3. Check that the `kube-dns` service has endpoints (see the command above). If it has none, the selector of the service does not match the CoreDNS pods or the pods are not ready.
4. Check that `nameserver` in the pod's `/etc/resolv.conf` is the ClusterIP of the `kube-dns` service.
5. If you edited the Corefile, restart CoreDNS: `kubectl rollout restart deployment coredns -n kube-system`
6. CoreDNS pods stuck in `Pending` or `ContainerCreating` on a new cluster usually mean that the CNI plugin is not installed yet.
