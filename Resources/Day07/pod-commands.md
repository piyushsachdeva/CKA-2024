


# PODS  - cheet sheet


## Two Ways To Use KUBCTL to create POD: 

imperative : 
------------
create nginx deployment
```SH
kubectl run nginx --image=nginx 
```

declerative : 
-
### 1. create nginx yaml file:
-  # template pod yaml has  : 
    - apiVersion
    - kind
    - metadata
    - spec
```YAML
# nginx-pod-1.yaml
# template pod yaml hasa : apiVersion, kind, metadata, spec
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod-1
  labels:
    name: demo
    type: frontend
spec:
  containers:
  - name: nginx-container
    image: nginx:1.28
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
    ports:
      - containerPort: 80
        protocol: TCP
```    
### 2. execute the yaml file 
```SH
#kubectl apply/create -f <file-name>
  # create - oly on creation 
  # apply  - create or update changes on a pod
kubectl apply -f ./nginx-pod-1.yaml
```

### To get the real values used in yaml file 
### to cretate a resource (pod,service ... ):
- command used : 
  
  __kubectl explain _[api-resouce-type]___ 

  - api-resouce-type type can be _pod/service/deployment/replicaset..._

```SH
kubectl api-resources  
# --> will show all of the resources that this command cover :

#     kubectl explain pod --recursive
# --  >   NAME                                SHORTNAMES   APIVERSION                        NAMESPACED   KIND
# --  >   bindings                                         v1                                true         Binding
# --  >   componentstatuses                   cs           v1                                false        ComponentStatus
# --  >   configmaps                          cm           v1                                true         ConfigMap
# --  >   endpoints                           ep           v1                                true         Endpoints
# --  >   events                              ev           v1                                true         Event
# --  >   limitranges                         limits       v1                                true         LimitRange
# --  >   namespaces                          ns           v1                                false        Namespace
# --  >   nodes                               no           v1                                false        Node
# --  >   persistentvolumeclaims              pvc          v1                                true         PersistentVolumeClaim
# --  >   persistentvolumes                   pv           v1                                false        PersistentVolume
# --  >   pods                                po           v1                                true         Pod
#  ....
``` 
## so : 

```SH
  kubectl explain pod 

           #  KIND:       Pod
           #  VERSION:    v1
           #  
           #  DESCRIPTION:
           #      Pod is a collection of containers that can run on a host. This resource is
           #      created by clients and scheduled onto hosts.
           #      
           #  FIELDS:
           #    apiVersion    <string>
           #      APIVersion defines the versioned schema of this representation of an object.
           #      Servers should convert recognized schemas to the latest internal value, and
           #      may reject unrecognized values. More info:
           #      https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
           #  
           #    kind  <string>
           #      Kind is a string value representing the REST resource this object
           #      represents. Servers may infer this from the endpoint the client submits
           #      requests to. Cannot be updated. In CamelCase. More info:
           #      https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
           #  
           #    metadata      <ObjectMeta>
           #      Standard object's metadata. More info:
           #      https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
           #  
           #    spec  <PodSpec>
           #      Specification of the desired behavior of the pod. More info:
           #      https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
           #  
           #    status        <PodStatus>
           #      Most recently observed status of the pod. This data may not be up to date.
           #      Populated by the system. Read-only. More info:
           #      https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
```


### this is very useful to understand the resource yaml file:

---
---


## DRY-RUN=client/server/none  


## if we want to create a resource YAML template - we can use  : ___dry-run=client___ parameter and export (-o) as yaml file 

the -o means --(o)utput format and can be yaml or json or text
```SH
# create nginx pod
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run=client -o  json
#kubectl create deployment nginx  --dry-run=client  --image=nginx --replicas=3 -o yaml
# dry-run - will not execute the command 
# -o yaml - will output as yaml format
# -o json - will output as json format

```
### JSON :
---


`kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run=client -o json`

```JSON
{
    "kind": "Pod",
    "apiVersion": "v1",
    "metadata": {
        "name": "nginx",
        "creationTimestamp": null,
        "labels": {
            "run": "nginx"
        }
    },
    "spec": {
        "containers": [
            {
                "name": "nginx",
                "image": "nginx",
                "ports": [
                    {
                        "containerPort": 80
                    }
                ],
                "resources": {}
            }
        ],
        "restartPolicy": "Never",
        "dnsPolicy": "ClusterFirst"
    },
    "status": {}
}
```

### it is very useful to add pipeline to a new file ( .. > < new-file > )  when using dry-run=client
  _example inline ..._
### YAML :
---

`kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run=client -o  yaml > run-nginx-template.yaml`

```YAML 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

# this way, the yaml will be saved inside the yaml file to be executed later. 
# so we used to **dry-run** to create a yaml fiel for next deploy of this pod 
```

## CHANGING PODS 
we can use 2 methods to change pod 
  - ### imperative
  ```SH
   kubectl edit pod <pod-name>

    # all of the pods YAML will be displayed in a vi editor and we can set values and save 
    # if the saved version has invalid fields ( syntax error )  the changes will not be commited
    # and we cant exit from edit window (vi)

  ```
  - ### declerative 
  edit the yaml file of the resource __(POD)__ with wanted values  and then execute : 
  ```SH
  kubectl apply -f ./changed_nginx-pod.yaml 
  ```

## DUPLICATING PODS YAML/JSON

if we have a running pod - we can use __imperative__ command to duplicate it and magke changes at the side - in an editor for next use withapply : 

1. ### duplicate the pod yaml file 
```SH
  kubectl get pod  nginx-pod-1 -o yaml > duplicated_nginx-pod-1
```

2. ### edit value of YAML pod 
```SH 
sed -i 's/containerPort: 80/containerPort: 81/' duplicated_nginx-pod-1 
```
3. ### uply new changes on pod : 

```
kubectl apply -f ./duplicated_nginx-pod-1 
```


## INSPECTING PODS - LOGS , DESCRIBE

there are 2 ways to see PODS logs 
### 1. DESCRIBE - 

desct=ribe actually used to probe any META DATA about a pod. 

it gives us documentation about thr node that the pod is in , the namespace and other infrastractural data 
 
 but it also gives us details about last failing logs

 so this is very useful command  

```SH
#kubectl describe pod < pod-name >
kubectl describe pod nginx-pod-1
```

describe show us full data about the pod, the namespace , the node etc ... 

more then this - we can see last logs of the pod 
it is very useful also when we have failover of pod - we ma inspect the last logs that are shown in the desribe output 

### 2. LOGS 

```SH 
# kubectl logs < pod-name >
kubectl logs nginx-pod-1 
```

  - #### TAIL LOGS : 
    if we want to tail logs (like tail -f) we can use -f flag : 

```SH
 kubectl logs -f nginx-pod-1 

# idubi@DESKTOP-82998RE  3.12  ~/.../Resources/Day07   Day07 ●  kubectl logs -f nginx-pod-1 
------------------------------------------------------------------------------------------------------
# /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
# /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
# 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
# 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
# /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
# /docker-entrypoint.sh: Configuration complete; ready for start up
# 2025/05/03 15:41:49 [notice] 1#1: using the "epoll" event method
# 2025/05/03 15:41:49 [notice] 1#1: nginx/1.28.0
# 2025/05/03 15:41:49 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
# 2025/05/03 15:41:49 [notice] 1#1: OS: Linux 5.15.167.4-microsoft-standard-WSL2
# 2025/05/03 15:41:49 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
# 2025/05/03 15:41:49 [notice] 1#1: start worker processes
# 2025/05/03 15:41:49 [notice] 1#1: start worker process 33
# 2025/05/03 15:41:49 [notice] 1#1: start worker process 34
# 2025/05/03 15:41:49 [notice] 1#1: start worker process 35
# 2025/05/03 15:41:49 [notice] 1#1: start worker process 36
# 2025/05/03 15:41:49 [notice] 1#1: start worker process 37 

```

## PODS - INTERACTIVE MODE 
this is especially useful if we want to look at logs 
or probe executions inside the pods container
just like in docker (i)nterac(t)ive  mode 
```SH 
#kubectl exec -it < pod-name > -- <command>
kubectl exec -it nginx-pod-1 -- sh
```


## DELETE A POD 

```SH 
# kubectl delete pod < pod-name >
kubectl delete pod nginx-pod-1

# ✘ idubi@DESKTOP-82998RE  3.12  ~/.../Resources/Day07   Day07 ●  kubectl get pods 
# NAME          READY   STATUS    RESTARTS     AGE
# 1st-nginx     1/1     Running   0            8h
# nginx-pod-1   1/1     Running   2 (8h ago)   8h
# idubi@DESKTOP-82998RE  3.12  ~/.../Resources/Day07   Day07 ●  kubectl delete pod 1st-nginx
# pod "1st-nginx" deleted
# idubi@DESKTOP-82998RE  3.12  ~/.../Resources/Day07   Day07 ●  kubectl get pods 
# NAME          READY   STATUS    RESTARTS     AGE
# nginx-pod-1   1/1     Running   2 (8h ago)   8h
# idubi@DESKTOP-82998RE  3.12  ~/.../Resources/Day07   Day07 ●  

```

---
---
---

# EXERCISE :

**Task 1**
- Create a pod using the imperative command and use nginx as the image
```SH
kubectl run nginx --image=nginx --restart=Never --port=80
```


**Task2**
- Create the YAML from the nginx pod created in task 1
```SH
 kubectl get pod nginx -o yaml > nginx-new.yaml
```
- Update the pod name in the YAML
```SH
sed -i 's/name: nginx/name: nginx-new/' nginx-new.yaml
cat  nginx-new.yaml|grep -C 3 'name: nginx'
#  vagrant@master-node:~/temp$ cat  nginx-new.yaml|grep -C 3 'name: nginx'
#    creationTimestamp: "2025-05-04T00:22:22Z"
#    labels:
#      run: nginx
#    name: nginx-new
#    namespace: default
#    resourceVersion: "249909"
#    uid: 7b44db2b-0ca3-4813-9740-494d9287e7ad
#  --
#    containers:
#    - image: nginx
#      imagePullPolicy: Always
#      name: nginx-new
#      ports:
#      - containerPort: 81
#        protocol: TCP
#  --
#      image: docker.io/library/nginx:latest
#      imageID: docker.io/library/#  nginx@sha256:c15da6c91de8d2f436196f3a768483ad32c258ed4e1beb3d367a27ed67253e66
#      lastState: {}
#      name: nginx-new
#      ready: true
#      restartCount: 0
#      started: true
#  

sed -i 's/containerPort: 80/containerPort: 81/' nginx-new.yaml
cat  nginx-new.yaml|grep -C 3 port
#  vagrant@master-node:~/temp$ cat  nginx-new.yaml|grep -C 3 port
#    - image: nginx
#      imagePullPolicy: Always
#      name: nginx
#      ports:
#      - containerPort: 81
#        protocol: TCP
#      resources: {}

```
- Use that YAML to create a new pod with the name nginx-new.
```SH
kubectl apply -f ./nginx-new.yaml

# vagrant@master-node:~/temp$ kubectl get pods
# NAME    READY   STATUS    RESTARTS   AGE
# nginx   1/1     Running   0          19m
# vagrant@master-node:~/temp$ kubectl apply -f ./
# duplicate-nginx-1.json  duplicate-nginx-1.yaml  nginx-new.yaml          nginx-pod-1.yaml
# vagrant@master-node:~/temp$ kubectl apply -f ./nginx-new.yaml
# pod/nginx-new created
# vagrant@master-node:~/temp$ kubectl get pods
# NAME        READY   STATUS    RESTARTS   AGE
# nginx       1/1     Running   0          20m
# nginx-new   1/1     Running   0          28s
# 


```


**Task3**
- Apply the below YAML and fix the errors, including all the commands that you run during the troubleshooting and the error message

```YAML
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: test
  name: redis
spec:
  containers:
  - image: rediss
    name: redis
    
```
```SH

echo "apiVersion: v1
kind: Pod
metadata:
  labels:
    app: test
  name: redis
spec:
  containers:
  - image: rediss
    name: redis" > failed-redis.yaml 

kubectl apply -f ./failed-redis.yaml
kubectl get pods

#  vagrant@master-node:~/temp$ kubectl get pdos
#  error: the server doesn't have a resource type "pdos"
#  vagrant@master-node:~/temp$ kubectl get pods
#  NAME        READY   STATUS             RESTARTS   AGE
#  nginx       1/1     Running            0          24m
#  nginx-new   1/1     Running            0          4m33s
#  redis       0/1     ImagePullBackOff   0          85s

kubectl logs redis 

#vagrant@master-node:~/temp$ kubctl logs redis
#-bash: kubctl: command not found
#vagrant@master-node:~/temp$ kubectl logs redis
#Error from server (BadRequest): container "redis" in pod "redis" is #waiting to start: trying and failing to pull image

kubectl describe pod redis

#  vagrant@master-node:~/temp$ kubectl describe pod redis
#  Name:             redis
#  Namespace:        default
#  Priority:         0
#  Service Account:  default
#  Node:             worker-node-1/192.168.133.167
#  Start Time:       Sun, 04 May 2025 00:45:05 +0000
#  Labels:           app=test
#  Annotations:      <none>
#  Status:           Pending
#  IP:               10.244.1.4
#  IPs:
#    IP:  10.244.1.4
#  Containers:
#    redis:
#      Container ID:
#      Image:          rediss
#      Image ID:
#      Port:           <none>
#      Host Port:      <none>
#      State:          Waiting
#        Reason:       ImagePullBackOff
#      Ready:          False
#      Restart Count:  0
#      Environment:    <none>
#      Mounts:
#        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8dz2k (ro)
#  Conditions:
#    Type                        Status
#    PodReadyToStartContainers   True
#    Initialized                 True
#    Ready                       False
#    ContainersReady             False
#    PodScheduled                True
#  Volumes:
#    kube-api-access-8dz2k:
#      Type:                    Projected (a volume that contains injected data from multiple sources)
#      TokenExpirationSeconds:  3607
#      ConfigMapName:           kube-root-ca.crt
#      ConfigMapOptional:       <nil>
#      DownwardAPI:             true
#  QoS Class:                   BestEffort
#  Node-Selectors:              <none>
#  Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
#                               node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
#  Events:
#    Type     Reason     Age                  From               Message
#    ----     ------     ----                 ----               -------
#    Normal   Scheduled  2m21s                default-scheduler  Successfully assigned default/redis to #  worker-node-1
#    Normal   Pulling    59s (x4 over 2m21s)  kubelet            Pulling image "rediss"
#    Warning  Failed     57s (x4 over 2m19s)  kubelet            Failed to pull image "rediss": failed to pull #  and unpack image "docker.io/library/rediss:latest": failed to resolve reference "docker.io/library/#  rediss:latest": pull access denied, repository does not exist or may require authorization: server message: #  insufficient_scope: authorization failed
#    Warning  Failed     57s (x4 over 2m19s)  kubelet            Error: ErrImagePull
#    Normal   BackOff    3s (x8 over 2m19s)   kubelet            Back-off pulling image "rediss"
#    Warning  Failed     3s (x8 over 2m19s)   kubelet            Error: ImagePullBackOff
#  

kubectl edit pod redis 

# change rediss --> redis   # -->  CTRL+x

kubectl get pod redis

#   vagrant@master-node:~/temp$ kubectl get pod redis
#   NAME    READY   STATUS    RESTARTS   AGE
#   redis   1/1     Running   0          15m



```

