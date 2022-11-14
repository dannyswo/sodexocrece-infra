AKS Bicep Configurations
------------------------

## AKS Managed Cluster resource

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

## Connectino with AKS Management Plane

```
az aks install-cli
az aks get-credentials --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01

az aks command invoke `
  --resource-group RG-demo-sodexo-crece `
  --name BRS-MEX-USE2-CRECESDX-SWO-KU01 `
  --command "kubectl get pods -n kube-system"

az aks command invoke --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01 --command "kubectl get namespaces"
az aks command invoke --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01 --command "kubectl get deployments --all-namespaces"
```

## Other Azure CLI commands

Login to ACR server: `az acr login -n azmxcr1hle650`

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