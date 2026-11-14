# Day 35/40 - Kubernetes ETCD Backup And Restore Explained

## Check out the video below for Day35 👇

[![Day 35/40 - Kubernetes ETCD Backup And Restore Explained](https://img.youtube.com/vi/R2wuFCYgnm4/sddefault.jpg)](https://youtu.be/R2wuFCYgnm4)

### What is etcd

etcd is the key-value database that stores the whole state of the cluster: every pod, deployment, secret, config map and so on. If you lose the etcd data, you lose the cluster, even if the nodes are still running. That is why taking a backup of etcd is an important admin task.

On a kubeadm cluster, etcd runs as a static pod on the control plane node. Its manifest is `/etc/kubernetes/manifests/etcd.yaml` and its data is in `/var/lib/etcd` on the node.

### Two tools: etcdctl and etcdutl

- `etcdctl` talks to a running etcd server over the network. You use it to take the snapshot.
- `etcdutl` works directly on etcd data files. You use it to check a snapshot and to restore it.

> Note: The video restores the snapshot with `etcdctl snapshot restore`. That subcommand was deprecated in etcd 3.5 and removed in etcd 3.6. Kubernetes 1.36 and 1.37 ship with etcd 3.6 and 3.7, so on a current cluster the restore has to be done with `etcdutl`. Taking the backup with `etcdctl snapshot save` has not changed.

### Install etcdctl and etcdutl on the control plane node

Check the etcd version of your cluster and download the same version of the tools.

```bash
kubectl -n kube-system describe pod -l component=etcd | grep Image:

ETCD_VER=v3.7.0
curl -LO https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzf etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo install -m 755 etcd-${ETCD_VER}-linux-amd64/etcdctl etcd-${ETCD_VER}-linux-amd64/etcdutl /usr/local/bin/

etcdctl version
etcdutl version
```

In the exam, the tools are already installed on the node where you need them.

### Find the endpoint and the certificates

etcd accepts only TLS connections with a client certificate. You get the endpoint and the certificate paths from the etcd manifest.

```bash
sudo grep -E "listen-client-urls|cert-file|key-file|trusted-ca-file|data-dir" /etc/kubernetes/manifests/etcd.yaml
```

| etcd flag in the manifest | etcdctl flag | Default value on a kubeadm cluster |
|---|---|---|
| `--listen-client-urls` | `--endpoints` | `https://127.0.0.1:2379` |
| `--trusted-ca-file` | `--cacert` | `/etc/kubernetes/pki/etcd/ca.crt` |
| `--cert-file` | `--cert` | `/etc/kubernetes/pki/etcd/server.crt` |
| `--key-file` | `--key` | `/etc/kubernetes/pki/etcd/server.key` |

### Take the backup

```bash
sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/etcd-snapshot.db
```

Check the snapshot:

```bash
sudo etcdutl --write-out=table snapshot status /opt/etcd-snapshot.db
```

> Note: Older guides, and the video, set `ETCDCTL_API=3` before every etcdctl command. API version 3 is the default since etcd 3.4, so you do not need it any more. Setting it does no harm.

### Restore the backup

1) Restore the snapshot into a **new** data directory. The directory must not exist already.

```bash
sudo etcdutl snapshot restore /opt/etcd-snapshot.db --data-dir /var/lib/etcd-from-backup
```

2) Point etcd to the new directory. Edit the etcd manifest and change the `hostPath` of the volume named `etcd-data` from `/var/lib/etcd` to `/var/lib/etcd-from-backup`. Do not change anything else.

```bash
sudo vi /etc/kubernetes/manifests/etcd.yaml
```

```yaml
  volumes:
  - hostPath:
      path: /var/lib/etcd-from-backup     # was /var/lib/etcd
      type: DirectoryOrCreate
    name: etcd-data
```

3) The kubelet sees that the manifest has changed and recreates the etcd pod on its own. This takes a minute or two, and `kubectl` does not respond during that time. Watch the containers with crictl:

```bash
sudo crictl ps | grep -E "etcd|kube-apiserver"
```

4) If the etcd or the API server containers do not come back after a couple of minutes, restart the kubelet.

```bash
sudo systemctl restart kubelet
```

5) Verify that the cluster is back in the state of the backup.

```bash
kubectl get nodes
kubectl get pods -A
kubectl get deploy
```

> Note: On a kubeadm cluster, also update `etcd.local.dataDir` in the `kubeadm-config` ConfigMap of the `kube-system` namespace to the new directory. If it still has the old path, the next `kubeadm upgrade` writes an etcd manifest that points back to the old directory.

### Common mistakes

- Forgetting `sudo`. The certificates in `/etc/kubernetes/pki/etcd` can only be read by root.
- Restoring into a directory that already exists.
- Editing `--data-dir` in the manifest but not the `hostPath` of the volume, or the other way round. The simplest change is the `hostPath` of the `etcd-data` volume only.
- Keeping a backup copy of `etcd.yaml` inside `/etc/kubernetes/manifests/`. The kubelet reads every file in that directory. Keep backups somewhere else, for example in `/tmp`.
