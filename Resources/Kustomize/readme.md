# Kustomize

Docs: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

## What is Kustomize

- Kustomize lets you customise plain Kubernetes YAML files for different environments without copying them and without templates.
- You keep one set of base manifests and describe the changes for each environment (namespace, name prefix, labels, replicas, image tag, patches) in a file called `kustomization.yaml`.
- It is built into kubectl, so there is nothing to install: `kubectl kustomize <dir>` prints the result and `kubectl apply -k <dir>` applies it.

Helm vs Kustomize in one line: Helm packages an application as a chart with templates and values. Kustomize patches plain YAML. Many teams use Helm for third-party software and Kustomize for their own manifests.

## A simple example

Consider an application with a deployment, a service, and a configmap.

```
myapp/
  ├── deployment.yaml
  ├── service.yaml
  ├── configmap.yaml
  └── kustomization.yaml
```

Move the common labels, name prefix/suffix and annotations out of each of the manifest files into the `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
labels:
  - pairs:
      app: mydemoapp
    includeSelectors: true
commonAnnotations:
  owner: platform-team
namePrefix: kustom-
nameSuffix: -v1
```

In this sample `kustomization.yaml`, we have five top level fields:

- `resources`: the manifest files (or directories) that Kustomize should read
- `labels`: the labels that you wish to be applied to all the resources. With `includeSelectors: true`, they are also added to the selectors of Deployments and Services
- `commonAnnotations`: the annotations that you wish to be applied to all the resources
- `namePrefix`: a prefix that is added to the name of every resource
- `nameSuffix`: a suffix that is added to the name of every resource

> Note: Older material uses `commonLabels` for labels. It is deprecated in favour of `labels`, which is what the example above uses.

Once you have created your `kustomization.yaml`, you can execute the command

```bash
kubectl kustomize .
```

It prints the final manifests with all the changes applied. Your original files are not modified. You can apply the changes by redirecting the output to a file:

```bash
kubectl kustomize . > manifest.yaml
kubectl apply -f manifest.yaml
```

or you can do both in one step with

```bash
kubectl apply -k .
```

Other useful commands:

```bash
kubectl diff -k .        # show what would change in the cluster
kubectl delete -k .      # delete everything that the kustomization creates
```

## Other common fields

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
namespace: dev            # put every resource in this namespace
images:                   # change the image name or tag without touching the manifest
  - name: nginx
    newTag: "1.27"
replicas:                 # change the replica count of a deployment
  - name: myapp
    count: 3
```

### ConfigMap Generation

Kustomize can also generate ConfigMaps and Secrets from files or literal values. This allows you to keep the configuration data in its own file, separate from the Kubernetes manifests.

Add the below field in the `kustomization.yaml`:

```yaml
configMapGenerator:
  - name: app-config
    envs:
      - config.properties
    literals:
      - LOG_LEVEL=info
```

- `envs` reads a file with `KEY=value` lines and creates one key per line. Use `files` if you want the whole file as a single key.
- Kustomize adds a hash of the content to the name of the generated ConfigMap, for example `app-config-7g2k9m5d8h`, and updates every reference to it in your Deployments. When the content changes, the name changes, and the Deployment rolls out new pods on its own.
- In your manifests, refer to the ConfigMap by its plain name, `app-config`.

`secretGenerator` works the same way for Secrets.

### Managing Multiple Environments

Earlier you had everything inside one directory. Now, you move the common manifests to a directory called `base` and create a directory called `overlays` at the same level. Inside `overlays`, you have one directory for each environment, with a `kustomization.yaml` that points to the base and lists the changes for that environment.

```
myapp/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── config.properties
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── replicas.yaml
    └── stage/
        ├── kustomization.yaml
        └── replicas.yaml
```

Let's assume you have a use case in which you have to deploy your dev resources in the `dev` namespace and your stage resources in the `stage` namespace. Also, for dev, you need 2 replicas, and for stage, you need 4 replicas of the deployment.

`base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
configMapGenerator:
  - name: app-config
    envs:
      - config.properties
```

`overlays/dev/kustomization.yaml` starts by referring to the base directory under `resources`, followed by the fields that you wish to override, for example the namespace. The changes to individual fields go into a patch file.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: dev
patches:
  - path: replicas.yaml
```

`overlays/dev/replicas.yaml` is a partial manifest. It has only the fields needed to find the object (`apiVersion`, `kind`, `metadata.name`) and the fields that you want to change:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
```

You then do the same for the stage directory, with `namespace: stage` and `replicas: 4`.

> Note: Older material uses the `bases` field to refer to the base directory and lists patch files directly under `patches` or `patchesStrategicMerge`. Both are deprecated. Use `resources` for the base and `patches` with `path:` as shown above.

To apply these configurations, simply use:

```bash
kubectl create namespace dev
kubectl kustomize overlays/dev        # check the output first
kubectl apply -k overlays/dev
```

## Kustomize and remote resources

A `resources` entry, or the argument of `kubectl kustomize`, can also be a URL to a Git repository. This is how many projects publish their install manifests. For example, this is the command that installs the Gateway API CRDs in the [day47](../day47-GatewayAPI) notes:

```bash
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.8.1" | kubectl apply -f -
```

## Practice tasks

1. Create a `base` with an nginx deployment named `myapp` and a ClusterIP service.
2. Create a `dev` overlay that sets the namespace to `dev`, adds the name prefix `dev-` and sets 2 replicas.
3. Create a `prod` overlay that sets the namespace to `prod`, sets 4 replicas and changes the image tag with the `images` field.
4. Add a `configMapGenerator` to the base, use the ConfigMap as env variables in the deployment, and check the generated name.
5. Run `kubectl kustomize` on both the overlays and compare the output, then apply both.
