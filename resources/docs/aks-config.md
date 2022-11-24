AKS Bicep Configurations
------------------------

## AKS Managed Cluster resource properties

Required by Sodexo:

* agentPoolProfiles.enableEncryptionAtHost: Encrypts OS and data disks of the Node Pool.
* addonProfiles: Configures AGIC and OMSAgent add-ons for Ingress and Application Gateway integration and monitoring with Log Analytics and Container Insights.
* securityProfile: Enables Workload Identity add-on to support the usage of Manage Identities by Pods in the cluster.
* enableRBAC: Enables Kubernetes RBAC.
* aadProfile: Enables Azure RBAC integration with Kubernetes RBAC.
* disableLocalAccounts: Disables local admin account used to gain admin privileges to the cluster. Requires Azure RBAC integration to be enabled.

Not allowed by Sodexo:

* windowsProfile: Configuration of user and password for Windows nodes. Not used.
* linuxProfile: Configuration of SSH keys for Linux nodes. Not needed.
* servicePrincipalProfile: Settings for AD Service Principal. Not recommended, Manage Identities are used instead.

Not needed:

* autoScalerProfile: Modifies cluster-autoscaler behavior. Default values are ok.
* httpProxyConfig: Deploys additional HTTP Proxy servers with the cluster. Not needed.
* storageProfile: Exposes Blob and File Storage as filesystem to container the cluster using Kubernetes CSI Driver. Not needed.
* enableNamespaceResources: Enables the creation of Namespaces via ARM.
* enablePodSecurityPolicy: Deprecated feature, legacy Pod identity solution.
* oidcIssuerProfile: Enables OIDC federation on the cluster.
* identityProfile: Identities associated with the cluster.
* diskEncryptionSetID: Uses a Disk Encryption Set to obtain a Managed Identity for the Managed Disks of the nodes to access the Key Vault to encrypt the content.
* agentpool.networkProfile: settings for allowed ports on nodes and Application Security Groups.
* networkProfile.loadBalancerProfile: Configuration of ingress with a Standard Load Balancer.
* networkProfile.natGatewayProfile: Configuration of egress with a NAT Gateway.

Optional:

* identityProfile: Object configuration, map of Managed Identities used by the cluster. Use system-assigned Managed Identities.
* privateLinkResources: Array of Private Link resources used by the cluster. Use AKS-managed Private Endpoint with private cluster option in apiServerAccessProfile.
* ingressProfile: Configures ngnix Ingress controller and external DNS controller (add-ons) to manage a DNS Zone and provide external web routing to the applications in the cluster.
* workloadAutoScalerProfile: Enables KEDA (Kubernetes Event-Driven Autoscaling) and enables VPA (Vertical Pod Autoscaler) in the cluster.
* podIdentityProfile: Configures AAD Pod-Managed Identity add-on on the cluster.
* azureMonitorProfile: Configures Prometeus monitoring add-on in the cluster.

## Maintainance and monitoring tasks

* Monitor CrashLoopBackOff (OOMKilled).
* Restart Linux nodes every day.

## Connection with AKS Management Plane

```
az aks install-cli
az aks get-credentials --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01
az aks get-credentials --resource-group BRS-MEX-USE2-CRECESDX-SWO-RG01 --name BRS-MEX-USE2-CRECESDX-SWO-KU01
```

```
az aks command invoke `
  --resource-group RG-demo-sodexo-crece `
  --name BRS-MEX-USE2-CRECESDX-SWO-KU01 `
  --command "kubectl get pods -n kube-system"

az aks command invoke --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01 --command "kubectl get namespaces"
az aks command invoke --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01 --command "kubectl get deployments --all-namespaces"
```

## Docker repository and images

```
az acr login -n azmxcr1hym659
az acr repository list --name azmxcr1hym659
az acr repository show --name azmxcr1hym659 --repository merchant-view
az acr repository show --name azmxcr1hym659 --repository helm/demoapp1
```

```
docker pull nginx:latest
docker tag nginx:latest azmxcr1hym659.azurecr.io/nginx:latest
docker push azmxcr1hym659.azurecr.io/nginx:latest
```

## Helm Charts management

```
USER_NAME="00000000-0000-0000-0000-000000000000"
PASSWORD=$(az acr login --name azmxcr1hym659 --expose-token --output tsv --query accessToken)
helm registry login azmxcr1hym659.azurecr.io --username $USER_NAME --password $PASSWORD
```

```
helm repo list
helm repo add [repository-name] [repository-url]

helm package [chart-director-path]
helm package .\src\charts\crecesdx-demoapp1-chart
helm lint [chart-directory-path]
helm lint .\src\charts\crecesdx-demoapp1-chart
helm push [package-file].tgz [acr-helm-oci-uri]
helm push crecesdx-demoapp1-1.0.0.tgz oci://azmxcr1hym659.azurecr.io/helm
az acr repository show --name [acr-name] --repository helm/[chart-name]
az acr repository show --name azmxcr1hym659 --repository helm/crecesdx-demoapp1
az acr manifest list-metadata --registry [acr-name] --name helm/[chart-name]
az acr manifest list-metadata --registry azmxcr1hym659 --name helm/crecesdx-demoapp1
helm search [keyword]

helm install [release-name] --dry-run --debug
helm install [release-name] [chart-uri] --version [chart-version] --namespace [namespace] --values [values-file-path]
helm install demoapp1 oci://azmxcr1hym659.azurecr.io/helm/crecesdx-demoapp1 --version 1.0.0 --namespace crecesdx --values values.swo.yaml
helm get manifest [release-name] --namespace [namespace]
helm get manifest demoapp1 --namespace crecesdx
helm list --namespace [namespace]
helm list --namespace crecesdx
helm status [release-name]
helm status demoapp1

helm uninstall [release-name] --namespace [namespace]
helm uninstall demoapp1 --namespace crecesdx
helm upgrade [release-name] [chart-uri] --version [version] --atomic --install
helm upgrade demoapp1 oci://azmxcr1hym659.azurecr.io/helm/crecesdx-demoapp1 --version 1.0.1 --atomic --install

az acr repository delete --name [acr-name] --image helm/[chart-name]
az acr repository delete --name azmxcr1hym659 --image helm/crecesdx-demoapp1
```

## Enable preview features and required providers for AKS identity add-ons

Enable aks-preview extension for AAD Workload Identity:

```
az extension add --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/EnableWorkloadIdentityPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService
```

Enable aks-preview extension for AAD Pod-Managed Identity:

```
az feature register --namespace "Microsoft.ContainerService" --name "EnablePodIdentityPreview"
az extension add --name aks-preview
```

## AKS Pod-Managed Identity Helm Chart installation

```
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
helm install aad-pod-identity aad-pod-identity/aad-pod-identity --namespace=crecesdx

kubectl apply -f azure-identity.k8s.yaml
kubectl apply -f azure-identity-binding.k8s.yaml
kubectl apply -f demo.k8s.yaml
```

## AKS initial setup

```
// AKS setup: crecesdx-namespace manifest, aad-pod-identity Helm Chart.

az aks get-credentials --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01
az acr login -n azmxcr1hym659

kubectl apply -f crecesdx-namespace.k8s.yaml

helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
helm install aad-pod-identity aad-pod-identity/aad-pod-identity --namespace=crecesdx

// App deployment with Helm Chart.

helm lint .\src\charts\crecesdx-demoapp1
helm package .\src\charts\crecesdx-demoapp1
helm push crecesdx-demoapp1-1.0.0.tgz oci://azmxcr1hym659.azurecr.io/helm
az acr repository show --name azmxcr1hym659 --repository helm/crecesdx-demoapp1
az acr manifest list-metadata --registry azmxcr1hym659 --name helm/crecesdx-demoapp1

helm install demoapp1 oci://azmxcr1hym659.azurecr.io/helm/crecesdx-demoapp1 --version 1.0.0 --namespace crecesdx --values .\config\values.swo.yaml
helm get manifest demoapp1 --namespace crecesdx

helm uninstall demoapp1
az acr repository delete --name azmxcr1hym659 --repository helm/crecesdx-demoapp1
```