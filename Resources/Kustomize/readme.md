# Kustomize (TODO- Work in progress)

Consider an application with a deployment, service, and a configmap. 

Here's how Kustomize brings everything together:

Move the common labels , prefix/suffix and annotations from each of the manifest files to the below kustomization.yaml file

```yaml
resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
commonLabels:
  app: mydemoapp
commonAnnotations:
  app: myanno
namePrefix: kustom-
nameSuffix: -v0.1
```

In this sample kustomization.yaml, we have five top level fields:

- resources: You can defines all your manifest yamls here
- commonLabels: The common labels that you wish to be applied to all the resources.
- commonAnnotations: The common annotations that you wish to be applied to all the resources.
- namePrefix: A valid prefix that will be applied to the resources name
- nameSuffix: A valid suffix that will be applied to the resources name

Once you have created your kustomization.yaml, you can execute the command
`kubectl kustomize .`

It will generate a manifest yaml by overridding all the fields in existing yamls, you can apply the changes by redirecting to a file such as

```yaml
kubectl kustomize . > manifest.yaml
kubectl apply -f manifest.yaml
```

or you can also run

`kubectl apply -k .`


### ConfigMap Generation

Kustomize also provides you the capabilities of generating the configmaps from external files which allows you to separate Kubernetes configuration data from Kubernetes manifests as per the best practices.

You achieve this by following the below steps:

Add the below field in the kustomization.yaml 

```yaml
configMapGenerator:
 - name: mapname
   env: config.properties
```

Update the reference of configmap inside the manifest yaml

### Managing Multiple Environments

you create a clear hierarchy of configurations:

Earlier you had everything inside a root directory, for example

```
$HOME/
  ├── deployment.yaml
  ├── service.yaml
  ├── config.properties
  └── kustomization.yaml
```

Now, you can move this to a root directory called Base and create a separate directory called overlays at the same level or Base directory. Inside overlays, you can have separate directories for each of the environments along with their respective customized version of files.

```
Base/
  ├── deployment.yaml
  ├── service.yaml
  ├── config.properties
  └── kustomization.yaml
overlays/
  ├── dev/
  │   ├── kustomization.yaml
  │   ├── replicas.yaml
  │   └── config.properties
  └── stage/
         └── kustomization.yaml
         ├── replicas.yaml
         └── config.properties
```


Let’s assume you have a usecase in which you have to deploy your dev resources in dev namespace and stage resources in stage namespace. Also, for dev, you need 2 replicas, for stage, you need 4 replicas of the deployment. 

For the file: overlays/dev/kustomization.yaml , you start by giving reference to the base folder under the bases top level field and the fields that you wish to override for example, namespace. You can also include custom fields such as replicas for each environment and create seperate replicas.yaml which has the configuration till the replicas field and then you perform the same actions for stage folder as well.

```yaml
bases:
  - ../../base
namespace: dev
patches:
  - replicas.yaml
```

To apply these configurations, simply use:
`kubectl apply -k overlays/dev`
