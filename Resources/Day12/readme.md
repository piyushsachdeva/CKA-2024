# Day 12/40 - Kubernetes Daemonset Explained - Daemonsets, Job and Cronjob in Kubernetes

## Check out the video below for Day12 👇

[![Day12/40 - Kubernetes Daemonset Explained - Daemonsets, Job and Cronjob in Kubernetes](https://img.youtube.com/vi/kvITrySpy_k/sddefault.jpg)](https://youtu.be/kvITrySpy_k)


### What is a daemonset?
- A daemon set is another type of Kubernetes object that controls pods. Unlike a deployment, the DS automatically deploys 1 pod to each available node. A node with a taint (for example the control plane node) is skipped unless the DS pod template has a matching toleration. You don't need to update the replica based on demand; the DS takes care of it by spinning X number of pods for X number of nodes.
- If you create a ds in a cluster of 5 nodes, then 5 pods will be created.
- If you add another node to the cluster, a new pod will be automatically created on the new node.

### Examples of daemonset
- kube-proxy
- CNI plugins such as calico, cilium and flannel
- monitoring and logging agents etc

### Daemonset for a 3 nodes cluster

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/bb803dc2-f9ab-4fe3-a0bb-0eacdfcf3ce0)



### Sample DS yaml used in the demo

```yaml
apiVersion: apps/v1
kind:  DaemonSet
metadata:
  name: nginx-ds
  labels:
    env: demo
spec:
  template:
    metadata:
      labels:
        env: demo
      name: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
  selector:
    matchLabels:
      env: demo
```

### What is a Job?
- A Job runs a pod until it completes successfully and then stops. It is used for one-time tasks such as a database migration or a batch calculation.
- `completions` is how many successful runs you need, `parallelism` is how many pods can run at the same time, and `backoffLimit` is how many retries are allowed before the Job is marked as failed.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  completions: 1
  backoffLimit: 4
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34.0
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```

### What is a CronJob?
- A CronJob creates a Job on a schedule, the same way cron does on a Linux machine.
- The schedule has five fields: `minute hour day-of-month month day-of-week`. For example `*/5 * * * *` means every 5 minutes and `0 2 * * 1` means 2:00 AM every Monday.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            command: ["/bin/sh", "-c", "date; echo Hello from the Kubernetes cluster"]
          restartPolicy: OnFailure
```

### Useful commands

```bash
kubectl get ds,job,cronjob
kubectl create job pi --image=perl:5.34.0 -- perl -Mbignum=bpi -wle 'print bpi(2000)'
kubectl create cronjob hello --image=busybox:1.28 --schedule="*/5 * * * *" -- /bin/sh -c "date; echo hello"
kubectl create job manual-run --from=cronjob/hello     # trigger a CronJob right now
kubectl logs job/pi
```
