
# Day 5/40 - What is Kubernetes - Kubernetes Architecture Explained ☸️


## Check out the video below for Day5 👇

[![Day 5/40 - What is Kubernetes - Kubernetes Architecture Explained](https://img.youtube.com/vi/SGGkUCctL4I/sddefault.jpg)](https://youtu.be/SGGkUCctL4I)


## Kubernetes Architecture

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/f15fbf28-5d18-4469-8a28-edd13678cbbf)

## Control plane node V/s worker node (a node is a machine that is part of the cluster, either virtual or physical)

> Note: Older material, including this video, calls the control plane node the "master" node. Kubernetes now uses the term "control plane" everywhere, and the node label is `node-role.kubernetes.io/control-plane`.

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/ef04ec3d-9f3a-4ac5-8a6a-31e877bfabf3)

## ApiServer :- Client interacts with the cluster using ApiServer

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/b8aeb299-9fc9-49da-9c87-0a6eb948ebd1)

## Scheduler - Decides which node each new pod should run on, based on resource requests, taints, affinity and other factors

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/189208b6-a01e-4e3f-baf9-ae9a9d0f3daf)

## Controller Manager - Runs the controllers (node, deployment, replicaset, job and so on) that keep the actual state of the cluster equal to the desired state

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/9aece452-6d76-452f-9c89-0f7825151312)

## ETCD Server - Key value database that stores the cluster state and configuration

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/81e037e3-78f0-41a7-8589-f2b4ec3af511)

## Kubelet - Agent on every node that receives pod specs from the API server and makes sure those containers are running, through the container runtime (containerd)

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/bd178509-c49c-4206-bc11-147ac91d2713)

## Kube-proxy - Runs on every node and maintains the network rules that route Service traffic to the right pods

> Note: kube-proxy implements Services (ClusterIP, NodePort and so on). Plain pod-to-pod networking is provided by the CNI plugin (Calico, Cilium, Flannel and others), not by kube-proxy.

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/e99ec3f5-5d73-4554-99d4-a7905d463f64)


