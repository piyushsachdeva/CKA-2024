# Day 38/40 - Troubleshooting control plane failure in Kubernetes

## Check out the video below for Day38 👇

[![Day 38/40 - Troubleshooting control plane failure in kubernetes](https://img.youtube.com/vi/z6XjbuRl6LE/sddefault.jpg)](https://youtu.be/z6XjbuRl6LE)

## Task for the video
Hands-on task details have been provided in [this file](task.md)

## Where to look

On a kubeadm cluster, the control plane components run as static pods. The kubelet starts them from the manifests in `/etc/kubernetes/manifests/` on the control plane node.

```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl logs -n kube-system kube-apiserver-<node-name>
kubectl describe pod -n kube-system kube-scheduler-<node-name>
```

When the API server itself is down, `kubectl` returns `The connection to the server <ip>:6443 was refused`. In that case, work on the control plane node directly:

```bash
sudo systemctl status kubelet
sudo journalctl -u kubelet --no-pager | tail -50
sudo crictl ps -a | grep -E "kube-apiserver|etcd|kube-scheduler|kube-controller"
sudo crictl logs <container-id>
ls /var/log/pods/
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

After you fix a manifest, the kubelet recreates the pod on its own. Give it a minute before you check again.

## Symptoms and likely causes

| Symptom | Component to check | Common causes |
|---|---|---|
| `kubectl` gets connection refused | kube-apiserver, etcd, kubelet | Typo in a flag or a wrong path of a certificate in `kube-apiserver.yaml`, wrong `--etcd-servers`, etcd not running, kubelet stopped, wrong server address in the kubeconfig |
| New pods stay in `Pending` and `describe` shows no events | kube-scheduler | Scheduler pod not running, wrong image, command or kubeconfig path in `kube-scheduler.yaml` |
| A deployment is created or scaled but no pods appear | kube-controller-manager | Controller manager pod not running, wrong flags or volume paths in its manifest |
| A static pod does not start at all | kubelet | Wrong `staticPodPath` in `/var/lib/kubelet/config.yaml`, YAML syntax error in the manifest |
| A node is `NotReady` | kubelet, container runtime, CNI | See [Day39](../Day39) |

## Things to verify in a manifest

- The image name and tag
- The command and every flag (look for typos such as `--etcd-server` or a wrong port)
- The paths of certificates and kubeconfig files, and that those files exist on the node
- That every `volumeMounts` entry has a matching `volumes` entry with the right `hostPath`
- The probe ports

> Note: Before you edit a manifest, take a copy of it outside `/etc/kubernetes/manifests/`, for example `sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/`. The kubelet reads every file in the manifests directory, so a backup copy kept there would also be started as a pod.
