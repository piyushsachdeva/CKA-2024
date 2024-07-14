# Day 17/40 - Kubernetes Autoscaling | HPA Vs VPA

## Check out the video below for Day17 👇

[![Day17/40 - Kubernetes Autoscaling | HPA Vs VPA](https://img.youtube.com/vi/afUL5jGoLx0/sddefault.jpg)](https://youtu.be/afUL5jGoLx0)

## Autoscaling types

![image](https://github.com/user-attachments/assets/684d96ca-60b7-4496-a180-dd1ab977a9bb)


## HPA v/S VPA

![image](https://github.com/user-attachments/assets/5b68a4b1-e5de-4086-9f55-6845bd420f1b)



### Sample commands used in the video:

```bash
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

kubectl get hpa php-apache --watch

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

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
