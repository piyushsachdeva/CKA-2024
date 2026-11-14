## Task 26/40

In this exercise, you will learn how to restrict pod-to-pod traffic with network policies

### Task details
1. Create a new kind cluster by disabling the default CNI
2. Install `Calico` Network Add-on to your Kind cluster
3. Create 3 deployments as below:
    - name: frontend, image: nginx, replicas: 1, containerPort: 80
    - name: backend, image: nginx, replicas: 1, containerPort: 80
    - name: db, image: mysql, replicas: 1, containerPort: 3306 (the mysql image needs the env variable `MYSQL_ROOT_PASSWORD` to start)
4. Expose all of these applications on a nodePort service with the same name as the deployment name
5. Do the connectivity test that all of your pods are able to interact with each other.
6. Create a network policy that selects the db pods and allows ingress on port 3306 only from the backend pods.
7. Verify that the backend pod can still connect to the db service on port 3306 and that the frontend pod no longer can.
