# Helm Tutorial

Docs: https://helm.sh/docs/ (this site is allowed in the CKA exam)

## What is Helm

- Helm is a package manager for Kubernetes. The same way you use `apt` on Ubuntu or `yum` on Red Hat to install software, you use Helm to install applications on a Kubernetes cluster.
- An application on Kubernetes is usually many objects: Deployments, Services, ConfigMaps, RBAC rules and so on. Without Helm, you would apply and maintain each of these YAML files yourself. With Helm, you install, upgrade and remove all of them together with a single command. For example, you can install Prometheus or an ingress controller with one `helm install`.
- Helm is a CNCF graduated project.

## Terms

- **Chart**: the package. It is a bundle of templated Kubernetes manifests and default values, like a `.deb` or `.rpm` file.
- **Repository**: the place where charts are stored and shared. It can be a classic HTTP chart repository or an OCI registry (the same kind of registry that stores container images).
- **Release**: a running instance of a chart in a cluster. You can install the same chart many times, and every install creates a new release with its own name.
- **Values**: the settings that you pass to a chart to customise it.
- **Revision**: every install, upgrade or rollback of a release creates a new revision, which is what makes a rollback possible.

## Install Helm

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
helm version
```

Helm uses the same kubeconfig as `kubectl`, so it talks to whichever cluster your current context points to.

> Note: The current major version is Helm 4, released in November 2025. Helm 3 still gets security fixes. The commands on this page work on both.

## Working with repositories and charts

The examples use [podinfo](https://github.com/stefanprodan/podinfo), a small demo web application that is published as a Helm chart.

```bash
# add a chart repository and refresh the local index
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm repo update
helm repo list

# search for charts
helm search repo podinfo            # in the repositories that you have added
helm search repo podinfo --versions   # all the available versions of a chart
helm search hub prometheus          # on Artifact Hub

# look at a chart before you install it
helm show chart podinfo/podinfo
helm show values podinfo/podinfo > values.yaml
```

Charts stored in an OCI registry do not need `helm repo add`. You pass the full `oci://` address:

```bash
helm show values oci://ghcr.io/nginx/charts/nginx-ingress
```

## Install, upgrade, roll back, uninstall

```bash
# install a release in its own namespace
helm install my-app podinfo/podinfo --namespace web --create-namespace

# install a specific chart version and override some values
helm install my-app podinfo/podinfo -n web --version <chart-version> --set replicaCount=2
helm install my-app podinfo/podinfo -n web -f my-values.yaml

# see what is installed
helm list -n web
helm list -A
helm status my-app -n web
helm get values my-app -n web
helm get manifest my-app -n web

# upgrade a release (change values or the chart version)
helm upgrade my-app podinfo/podinfo -n web --set replicaCount=3
helm upgrade --install my-app podinfo/podinfo -n web     # install if it does not exist, upgrade if it does

# history and rollback
helm history my-app -n web
helm rollback my-app 1 -n web

# remove a release
helm uninstall my-app -n web
```

Things to remember:
- A release lives in a namespace. If you forget `-n <namespace>`, `helm list` shows nothing and `helm upgrade` cannot find your release.
- `--set` values win over `-f` files, and both win over the chart's default `values.yaml`.
- When you pass new values to `helm upgrade`, the values that you set at install time are reset to the chart defaults unless you pass them again or add `--reuse-values`.

## Render a chart without installing it

`helm template` prints the final manifests without talking to the cluster. This is useful to check what a chart will create, or to save the manifests to a file and apply them yourself.

```bash
helm template my-app podinfo/podinfo -n web --set replicaCount=2 > podinfo.yaml
helm install my-app podinfo/podinfo -n web --dry-run=client
```

## Charts that come with CRDs

Many charts (cert-manager, ingress and gateway controllers, monitoring stacks) need Custom Resource Definitions. Each chart has its own value to control whether Helm installs the CRDs. Check `helm show values` for it. For example, cert-manager uses `crds.enabled`:

```bash
helm install cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.21.3 \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true
```

## Structure of a chart

`helm create NAME` creates a starter chart with the following structure:

```
NAME/
├── Chart.yaml        # metadata about the chart: name, version, appVersion
├── values.yaml       # default values for the templates
├── charts/           # charts that this chart depends on
├── templates/        # manifest templates that are filled with the values
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── _helpers.tpl
│   ├── NOTES.txt     # text printed after install
│   └── tests/
└── .helmignore       # files to leave out when packaging the chart
```

A template reads its settings from `values.yaml`:

```yaml
# templates/deployment.yaml (part)
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

```yaml
# values.yaml (part)
replicaCount: 1
image:
  repository: nginx
  tag: "1.27"
```

You can use a single chart for multiple environments by keeping one values file per environment:

```bash
helm create myapp
helm lint myapp                                   # check the chart for errors
helm template myapp ./myapp                       # render it locally
helm install myapp-dev ./myapp -n dev --create-namespace -f values-dev.yaml
helm install myapp-prod ./myapp -n prod --create-namespace -f values-prod.yaml
helm package myapp                                # creates myapp-0.1.0.tgz
```

## Helm 2 vs Helm 3 vs Helm 4

- Helm 2 needed a server-side component called Tiller that ran as a pod in the cluster with wide permissions. Helm 3 removed Tiller. Helm now talks to the API server directly with your own kubeconfig permissions, and stores the release information as Secrets in the namespace of the release.
- Helm 3 added support for OCI registries and for a JSON schema to validate values.
- Helm 4 keeps the same commands and still installs Helm 3 charts. The main changes are under the hood, such as server-side apply for new installs and a new plugin system.

## Practice tasks

1. Install Helm and add the podinfo repository.
2. Install the podinfo chart as a release named `web` in the namespace `web`, with 2 replicas.
3. Upgrade the release to 3 replicas and check the history.
4. Roll back to revision 1 and confirm the number of replicas.
5. Render the chart with `helm template` into a file, and count how many Kubernetes objects it creates.
6. Uninstall the release and delete the namespace.
