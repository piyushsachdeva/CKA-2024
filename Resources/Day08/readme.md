## Check out the task.md file for the hands-on exercises

## Cheatsheet for Kubernetes commands:
https://kubernetes.io/docs/reference/kubectl/quick-reference/

### Replicaset
https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/3e9792d4-1127-44b4-a6ec-cdc2a82219e3)


### Deployment
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/b888d272-c623-4a00-8381-45c25ce9d9c0)


### Replication Controller
https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/

> Note: ReplicationController is a legacy API. It is covered in the video only so that you understand how ReplicaSet and Deployment came about. In real clusters and in the exam you will use a Deployment, which manages ReplicaSets for you.

### Commands used in the video

```bash
# create a deployment and generate its YAML without creating it
kubectl create deployment nginx-deploy --image=nginx --replicas=3
kubectl create deployment nginx-deploy --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml

# scale
kubectl scale deployment nginx-deploy --replicas=5

# rolling update and rollback
kubectl set image deployment/nginx-deploy nginx=nginx:1.27
kubectl rollout status deployment/nginx-deploy
kubectl rollout history deployment/nginx-deploy
kubectl rollout undo deployment/nginx-deploy
kubectl rollout undo deployment/nginx-deploy --to-revision=1
```


