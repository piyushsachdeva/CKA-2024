# Day 15/40 - Kubernetes node affinity explained

## Check out the video below for Day15 👇

[![Day15/40 - Kubernetes node affinity explained](https://img.youtube.com/vi/5vimzBRnoDk/sddefault.jpg)](https://youtu.be/5vimzBRnoDk)


## Beyond Node Selectors: Introducing Affinity 🚀

Node Selectors are great for basic pod placement based on node labels. But what if you need more control over where your pods land? Enter **Node Affinity**! This feature offers advanced capabilities to fine-tune pod scheduling in your Kubernetes cluster.

---

## Node Affinity: The Powerhouse 🔥

Node Affinity lets you define complex rules for where your pods can be scheduled based on node labels. Think of it as creating a wishlist for your pod's ideal home!

### Key Features:
- **Flexibility**: Define precise conditions for pod placement.
- **Control**: Decide where your pods can and cannot go with greater granularity.
- **Adaptability**: Allow pods to stay on their nodes even if the labels change after scheduling.

---

## Properties in Node Affinity
- requiredDuringSchedulingIgnoredDuringExecution
- preferredDuringSchedulingIgnoredDuringExecution

## Required During Scheduling, Ignored During Execution 🛠️

This is the strictest type of Node Affinity. Here's how it works:

1. **Specify Node Labels**: Define a list of required node labels (e.g., `disktype=ssd`) in your pod spec.
2. **Match Requirement**: The scheduler only places the pod on nodes whose labels satisfy the expression. If no node matches, the pod stays in `Pending`.
3. **Execution Consistency**: Once scheduled, the pod remains on the node even if the label changes.

### Example: Targeting SSD Nodes 💾

Suppose your pod needs high-speed storage. You can create a deployment with a Node Affinity rule that targets nodes labeled `disktype=ssd`.

**YAML Configuration:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: redis
  name: redis-3
spec:
  containers:
  - image: redis
    name: redis
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
```

Label a node so that the pod can be scheduled:

```bash
kubectl label node worker01 disktype=ssd
kubectl get nodes --show-labels
kubectl label node worker01 disktype-      # removes the label
```

## Preferred During Scheduling, Ignored During Execution

This is the soft version. The scheduler tries to find a node that matches the rule, and if there is none, it still schedules the pod on some other node. Each rule has a `weight` from 1 to 100, and nodes that match rules with a higher weight are preferred.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis-preferred
spec:
  containers:
  - image: redis
    name: redis
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
```

## Operators

- `In` / `NotIn`: the label value is (or is not) in the given list
- `Exists` / `DoesNotExist`: the label key is (or is not) present on the node. Do not give `values` with these two
- `Gt` / `Lt`: the label value, read as a number, is greater than or less than the given value

## nodeSelector vs node affinity

`nodeSelector` is the simple form: the node must have all the listed labels with exactly those values. Node affinity can do everything `nodeSelector` does and adds the operators above and the soft `preferred` rules.

```yaml
spec:
  nodeSelector:
    disktype: ssd
```


