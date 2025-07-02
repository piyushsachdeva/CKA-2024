# What is Kubernetes - Kubernetes Architecture Explained
## 40 days of K8s - CKA challenge (05/40)

@piyushsachdeva

[Day 5/40 - What is Kubernetes - Kubernetes Architecture Explained](https://www.youtube.com/watch?v=SGGkUCctL4I)

this post summerise the Architecture of K8s and its main processes

<hr/>

## the Architecture of K8s and its main processes

a K8s cluster contains 2 types of nodes: 

## Master NODE (control plane)
 - ETCD 
 - API SERVER
 - SCHEDULER 
 - CONTROLLER MANAGER
##  Worker NODE 
 - KUBELETS
 - KUBE PROXY

<HR/>

## 1.  MASTER NODE - control plane
the master node consists 3 main processes and ETCD Component.
- __ETCD__ - _(Extended Tree Configuration Database)_ this is a __key:value _(like JSON objects)___ database that represent the metadata of the clkuster. 
it includes all of the structural entities statuses in a given time. 
whenever a change is needed, of a new entity or current one configuration - this change is updated to the ETCD and upon the new value and current value - the new entity will be created/updated. 

- __SCHEDULER__ -  SCHEDULER is in charge of 1 specific thing : schedule the creation of a new POD into a specific NODE.    
___Scheduler only acts on unscheduled Pods___ :  Pods with spec.nodeName not set.

```
    The only times that happens 
    ---------------------------------------------------------
    o	A new Pod is created
    o	Directly (kubectl run)
    o	Indirectly via a controller (Deployment, Job, ReplicaSet)
    o	An existing Pod is deleted and the controller creates a replacement
    o	A Pod gets rescheduled (after Node failure, eviction, etc.)


        When the scheduler is not involved
    ---------------------------------------------------------
    o	If you run any command that doesn't result in a new Pod, the scheduler does nothing.


```
- API SERVER - is the main component of the Kubernetes cluster - after the ETCD

```
what is API SERVER in charge of :
---------------------------------
o   validate any call from CLI or rest call 
o   store the request in ETCD
o   acts as a client to control manager or scheduler to read from ETCD 
o   send a message to the specific NODE's kubelete and trigger it,
    when any changes need to be done inside it.
```


if any of the _ETCD_ or  _API Server_ is failing, they must be recovered. 
but as long they are down - current nodes function autonomly, but any change in the cluster is impossible. 
the kubeletes (will speak about it soon) will keet the current status in the node, but any change in replicaset or pods or any other status of the cluster cant be done. 

if the APIServer is failing - there is no connection between the components of the cluster, and command cant be setnt to the K8s cluster from outside of the cluster (no cli or api commmands)

 - CONTROLLER MANAGER - monitor all ofthe controllers inside the cluster. 
 the control is done throught the ETCD.  it is useing the API sServer to read from the rtcd - the cesesary data about the different components in the cluster nodes.    
 it runs several __control loops__, each loop is a controller, responsible for managing a specific Kubernetes ___resource type___    
 how does it monitor ? by watching the ETCD via the ___API SEVER___

 #### Just like the scheduler, the controller manager watches for changes to objects it's responsible for, via the use of __API SERVER__

 ## example:

 ```
 Example:
	If you create a Deployment, the Deployment controller:
    -------------------------------------------------------
    o   Watches for Deployments via the API server.
    o   Sees that it needs 3 replicas.
    o   Creates 3 ReplicaSets via the API server.
    o   ReplicaSet controller sees that, and creates 3 Pods.
    o   All of this flows through the API server.

 ```

The control loop pattern:
1.	Watch: Observe resources via the API server.
2.	Compare: Desired state vs current state.
3.	Act: If there's a diff, make changes via the API server.
4.	API server updates etcd.
________________________________________

### here is a list of controllers (loops) inside the conttroller manager:

| Controller Name                    | What it Manages                    | Example Behavior                                           |
|-------------------------------------|------------------------------------|------------------------------------------------------------|
| Node Controller                    | Node health/status                | Marks Nodes as NotReady if kubelet is unresponsive         |
| Replication Controller             | ReplicationController resources   | Ensures the desired number of old-style RCs                |
| ReplicaSet Controller              | ReplicaSet resources              | Maintains correct number of Pods                           |
| Deployment Controller              | Deployment resources              | Handles rolling updates, rollback                         |
| StatefulSet Controller             | StatefulSet resources             | Ensures ordered, unique Pod identities                     |
| DaemonSet Controller               | DaemonSet resources               | Makes sure one Pod per Node is running                     |
| Job Controller                     | Job resources                     | Manages Pods for short-lived jobs                          |
| CronJob Controller                 | CronJob resources                 | Creates Jobs based on a schedule                           |
| Service Controller                 | Service resources                 | Updates iptables/IPVS rules, interacts with cloud LB       |
| EndpointSlice Controller           | EndpointSlices                    | Replaces legacy Endpoints, more scalable                   |
| Namespace Controller               | Namespace lifecycle               | Cleans up resources when namespace is deleted              |
| PersistentVolume (PV) Controller   | PersistentVolume binding          | Matches PVCs to available PVs                              |
| PersistentVolumeClaim (PVC) Controller | PVC lifecycle                  | Manages volume provisioning and binding                    |
| ResourceQuota Controller           | ResourceQuota enforcement         | Blocks creation if limits exceeded                         |
| ServiceAccount Controller          | Default service accounts          | Automatically creates default ServiceAccounts in namespaces |
| Token Controller                   | Generates secrets for service accounts | Token rotation and creation                           |
| CertificateSigningRequest Controller | CSR approval and tracking       | Used in TLS bootstrap and cert renewal                     |

### Cloud-specific Controllers (when running in a cloud environment)These run only if you’ve configured a cloud provider like AWS, GCP, or Azure:

| Controller Name                 | Purpose                                          |
|----------------------------------|--------------------------------------------------|
| CloudNode Controller             | Syncs Node metadata with cloud provider          |
| CloudRoute Controller            | Manages routing tables (for overlay networks)    |
| Service LoadBalancer Controller  | Provisions cloud load balancers for type: LoadBalancer services |

<HR/>

## 2.  Worker NODE 
### this are the worker nodes components and they run on any node
 KUBELET - Running and maintaining application Pods
-  kubelets are in charge of maintainence of the NODE. 
-   talks to the container runtime (containerd / docker ) to ensure pods are erunning properly
-   talks to the ETCD via the API server to check new tasks/changes on the pod
-    it is critical for rnning and maintainnt the pods inside the node
 
KUBE-PROXY - Enabling Service discovery and internal communication
-   manages the network traffic rules on the node 
-   Configures network routing rules so Services can work
-   talks to API Server (to learn about Services and Endpoints)
and Local iptables / IPVS system
-   Set up iptables or IPVS rules, and Load balance traffic inside the cluster


