# Day 40/40 - JSONPath Tutorial - Advanced Kubectl Commands

## Check out the video below for Day40 👇

[![Day 40/40 - JSONPath Tutorial - Advanced Kubectl Commands](https://img.youtube.com/vi/l9_UDSaiFj4/sddefault.jpg)](https://youtu.be/l9_UDSaiFj4)

## Task for the video
Hands-on task details have been provided in [this file](task.md)

## JSON vs YAML

Both formats describe the same data. YAML uses indentation and is easier to read, JSON uses braces and brackets. `kubectl` can print any object in both formats:

```bash
kubectl get pod nginx -o yaml
kubectl get pod nginx -o json
```

## JSONPath basics

JSONPath is a query language to pull specific fields out of JSON output. First look at the full JSON to find the path of the field that you need, then write the query.

| Expression | Meaning |
|---|---|
| `$` | The root object. kubectl adds it for you, so you can leave it out |
| `.field` | A child field |
| `[0]` | An item of a list, by index |
| `[*]` | All the items of a list |
| `[?(@.field=="value")]` | Only the list items that match the condition |
| `{range .items[*]} ... {end}` | Loop over a list |
| `{"\n"}` and `{"\t"}` | New line and tab |

A `kubectl get` on several objects returns a list, so the query starts with `.items[*]`. A `kubectl get` on one named object returns that object directly.

```bash
# name of every pod
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# image of the first container of one pod
kubectl get pod nginx -o jsonpath='{.spec.containers[0].image}'

# one line per pod: name and IP
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'

# InternalIP of every node
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'

# name and taints of every node
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints[*].effect}{"\n"}{end}'

# decode one key of a secret
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d
```

## Custom columns

```bash
kubectl get nodes -o custom-columns=NODE:.metadata.name,CPU:.status.capacity.cpu
kubectl get pods -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,IMAGE:.spec.containers[*].image
```

## Sorting and filtering

```bash
kubectl get pods --sort-by=.metadata.creationTimestamp
kubectl get pv --sort-by=.spec.capacity.storage
kubectl get nodes --sort-by=.status.capacity.cpu -o custom-columns=NODE:.metadata.name,CPU:.status.capacity.cpu
kubectl get pods -A --field-selector status.phase=Running
kubectl get pods -l env=prod --no-headers | wc -l
```

## Other commands that save time

```bash
kubectl explain pod.spec.containers.livenessProbe
kubectl explain deployment --recursive | less
kubectl api-resources
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment web --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml
kubectl get pod nginx -o yaml > pod.yaml
```
