# Day 14/40 - Taints and Tolerations in Kubernetes 📘🚀

## Check out the video below for Day14 👇

[![Day14/40 - Taints and Tolerations in Kubernetes](https://img.youtube.com/vi/nwoS2tK2s6Q/sddefault.jpg)](https://youtu.be/nwoS2tK2s6Q)

# Taints and Tolerations in Kubernetes 🚧📜

In this guide, we'll explore taints and tolerations in Kubernetes, essential tools for managing where pods can be scheduled in your cluster.

---

## Taints: Putting Up Fences 🚫

Think of taints as "only you are allowed" signs on your Kubernetes nodes. A taint marks a node with a specific characteristic, such as `"gpu=true"`. By default, pods cannot be scheduled on tainted nodes unless they have a special permission called toleration. When a toleration on a pod matches with the taint on the node then only that pod will be scheduled on that node.

---

## Tolerations: Permission Slips for Pods ✅

Toleration allows a pod to say, "Hey, I can handle that taint. Schedule me anyway!" You define tolerations in the pod specification to let them bypass the taints.

---

## Taints & Tolerations in Action 🎬

Here’s a breakdown of the commands to manage taints and tolerations:

### Tainting a Node:

The format of a taint is `key=value:effect`.

```bash
kubectl taint nodes node1 gpu=true:NoSchedule
```

This command taints node1 with the key "gpu", the value "true" and the effect "NoSchedule". Pods without a toleration for this taint won't be scheduled there.

To see the taints on a node:

```bash
kubectl describe node node1 | grep -i taints
```

To remove the taint, you add - at the end of the command, like below.

```bash
kubectl taint nodes node1 gpu=true:NoSchedule-
```

### Taint effects

- `NoSchedule`: new pods without a matching toleration are not scheduled on the node. Pods that are already running there are not touched.
- `PreferNoSchedule`: the scheduler tries to avoid the node but can still use it if there is no other choice.
- `NoExecute`: new pods are not scheduled, and pods that are already running on the node without a matching toleration are evicted.

### Adding toleration to the pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: redis
  name: redis
spec:
  containers:
  - image: redis
    name: redis
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

>Note: This pod specification defines a toleration for the taint `gpu=true:NoSchedule`. This allows the pod to be scheduled on the tainted node. With `operator: "Exists"` you leave out the `value`, and the toleration matches any value of that key.

>Note: A toleration only allows a pod onto a tainted node. It does not force the pod to go there, so the pod can still land on any other node without a taint. To make sure a pod runs on a particular node, combine the toleration with a node selector or node affinity.

### Labels vs Taints/Tolerations

Labels group nodes based on size, type, env, etc. A label on a node does nothing to scheduling by itself. It only matters when a pod asks for it through a `nodeSelector` or node affinity. A taint works the other way round: the node pushes pods away unless they tolerate the taint.

### Limitations to Remember 🚧

Taints and tolerations are powerful tools, but they have limitations. They cannot handle complex expressions like "AND" or "OR." 
So, what do we use in that case? We use a combination of taints, tolerations, and node affinity, which we will discuss in the next video.

