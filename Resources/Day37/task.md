## Task 37/40

In this exercise, you will explore how to troubleshoot application failures in Kubernetes from CKA exam perspective
> [!NOTE]
> If you do not already have a Kubernetes cluster, you can create a Kubernetes cluster using `kubeadm` by following Day 27 video.

### Task details
1. Login to your cluster and clone the Git repository as below
   ` git clone https://github.com/piyushsachdeva/example-voting-app`
2. cd into the cloned directory
3. Apply the manifests as below
`kubectl create -f k8s-specifications/`
4. This repo is a fork of example voting app by Docker, we have made some changes to the manifests so that it can be used as a sample app
for the Kubernetes Application troubleshooting video.There are some intentional errors introduced in the application to demo
the application troubleshooting scenario for a simple web app. You should be able to fix those errors.
