AKS Bicep Configurations
------------------------

## AKS Managed Cluster resource

Required by Sodexo:

* agentPoolProfiles.enableEncryptionAtHost: Encrypts OS and data disks of the Node Pool.

Not allowed by Sodexo:

* linuxProfile: Used to enable SSH on Node Pool VMs. 

Not needed:

* autoScalerProfile: Used to modify cluster-autoscaler behavior. Default values are ok.
* httpProxyConfig: Used to deploy additional HTTP Proxy servers with the cluster. Not needed.
* storageProfile: Used to expose Blob and File Storage as filesystem to container the cluster using Kubernetes CSI Driver. Not needed.

Optional:

* identityProfile: Object configuration, map of Managed Identities used by the cluster. Use system-assigned Managed Identities.
* privateLinkResources: Array of Private Link resources used by the cluster. Use AKS-managed Private Endpoint with private cluster option in apiServerAccessProfile.
* podIdentityProfile: Azure ...

## Maintainance and monitoring tasks

* Monitor CrashLoopBackOff (OOMKilled).
* Restart Linux nodes every day.

## Connectino with AKS Management Plane

```
az aks get-credentials --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01
az aks command invoke \
  --resource-group RG-demo-sodexo-crece \
  --name BRS-MEX-USE2-CRECESDX-SWO-KU01 \
  --command "kubectl get pods -n kube-system"

az aks command invoke --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01 --command "kubectl get namespaces"
az aks command invoke --resource-group RG-demo-sodexo-crece --name BRS-MEX-USE2-CRECESDX-SWO-KU01 --command "kubectl get deployments --all-namespaces"
```

## Connection to ACR

```
az acr login -n azmxcr1hle650
```