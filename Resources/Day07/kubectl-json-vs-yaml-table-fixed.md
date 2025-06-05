


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

`kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run=client -o  yaml`
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

```



