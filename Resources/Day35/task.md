## Task 35/40

In this exercise, you will explore the Kubernetes ETCD backup and restore process.

> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a Kubernetes cluster using `kubeadm` by following Day 27 video.

### Task details
1. Login to your control plane node
2. Ensure all the nodes are in ready status
3. Find out version of etcd
4. Create an nginx deployment with 2 pods
5. Identify endpoint url, server certs and ca certs
6. Make sure `etcdctl` and `etcdutl` are installed on the node
7. Run `etcdctl snapshot --help` and `etcdutl snapshot --help` to view the different options
8. Using the above help, take the backup of the etcd cluster to the file `/opt/etcd-snapshot.db`
9. Delete the deployment
10. Using `etcdutl`, restore the original state of the cluster from the backup file at `/opt/etcd-snapshot.db` to the directory `/var/lib/etcd-from-backup`
11. Point ETCD to the new directory with the restored backup
12. Restart etcd pod
13. Check the deployment using `kubectl get deploy` , make sure that it is available as you have restored the backup prior to deleting the deployment
