# Day 17/40 - Kubernetes Autoscaling | HPA Vs VPA

## Check out the video below for Day17 👇

[![Day17/40 - Kubernetes Autoscaling | HPA Vs VPA](https://img.youtube.com/vi/afUL5jGoLx0/sddefault.jpg)](https://youtu.be/afUL5jGoLx0)

## Autoscaling types

![image](https://github.com/user-attachments/assets/684d96ca-60b7-4496-a180-dd1ab977a9bb)


## HPA v/S VPA

![image](https://github.com/user-attachments/assets/5b68a4b1-e5de-4086-9f55-6845bd420f1b)



### Sample commands used in the video:

```bash
# create the HPA: keep average CPU at 50% of the requested CPU, between 1 and 10 replicas
kubectl autoscale deployment php-apache --cpu=50% --min=1 --max=10

# generate load from a second terminal
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

# watch the HPA scale the deployment up, and down again after you stop the load
kubectl get hpa php-apache --watch
```

> Note: The video uses `--cpu-percent=50`. That flag is deprecated in recent kubectl versions in favour of `--cpu=50%`. Both create the same HPA.

### Things to remember

- HPA needs the metrics server (see the [Day16](../Day16) folder) and it needs CPU **requests** on the containers. Without requests, the target shows `<unknown>` and nothing scales.
- HPA changes the number of pods (horizontal). VPA changes the CPU and memory requests of the pods (vertical). VPA is not part of core Kubernetes and is installed as an add-on.
- Since Kubernetes 1.35, the resources of a running pod can be changed in place without recreating the pod: `kubectl patch pod <pod> --subresource resize --patch '{"spec":{"containers":[{"name":"<container>","resources":{"requests":{"cpu":"500m"}}}]}}'`
- Cluster Autoscaler and Karpenter add or remove nodes. Node auto-provisioning (NAP), mentioned in the video, is the GKE feature for the same job.
- Scale down is slow on purpose. The HPA waits for 5 minutes by default (`behavior.scaleDown.stabilizationWindowSeconds`) before it removes pods.

### Sample YAML used in the video

1. Deploy.yaml

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
```

2. hpa.yaml

```YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```
