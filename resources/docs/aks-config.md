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
* podIdentityProfile: Azure 