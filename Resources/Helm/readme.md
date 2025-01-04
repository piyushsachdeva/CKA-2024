## Helm Tutorial ( TODO- Work in progress)

### What is Helm
- Package manager for Kubernetes like we have apt for ubuntu, yum for redhat, the same way we have package manager for Kubernetes which is called.

When you have to install a package in Ubuntu, you to the package manager reposirtoy and install using that. Easy way to install the package
In Kubernetes, helm provides the similar funcationality
e.g you wants to install prometheus, you can just install it using helm
CNCF project
- Create, find, share and use software packages on kubernetes

- Package in helm is called a Chart or a helm chart like yum rpm file, apt dpkg file, its a bundle of tools, binaries and dependencies
- Reporistory: central storage for chart management like Github or Dockerhub
- Release: Instace of a running chart , containers in dockers

- charts are reusable, you can install a single chart multiple times, every time it will create a new release
- you can also search helm charts in the kubernetes repository

- Helm install resources in following order: Namespace, netpol, quota, limitrange and so on( you dont have to remember this)
- add a link to the dcoumentation here:

## Helm commands
https://helm.sh/docs/

- `helm create NAME` will create the following structure
|-- .helmignore
- chart.yaml ( metadata about the chart)
- values.yaml ( override the values in the file)
- charts/ (chart dependency)
- template/ 
    /tests/

- helm lint to check for syntactical error

Sample of a HelloWorld chart
https://github.com/Azure-Samples/helm-charts/tree/master/chart-source/aks-helloworld

templates/deployment.yaml ( template that will fetch the value from values.yaml)

you can update the values.yaml as per your needs
You can use the single chart for multiple environments

helm install chartname ( install the chart)
you can also pass the customer values.yaml for multi-environment

## todo: Add the namespace in the template to deploy the chart as mulrtiple version

## Helm v2 VS Helm 3
- Removal of Tiller ( used to be deployed as a pod in the cluster)
- helm search now support both local search and remote search
  
