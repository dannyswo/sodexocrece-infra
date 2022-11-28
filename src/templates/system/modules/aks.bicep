/**
 * Module: aks
 * Depends on: managed-identities, network (optional), app-gateway, monitoring-loganalytics-workspace
 * Used by: system/main-system
 * Common resources: RL09, AD03
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@description('Name of the Managed Identity used by AKS Managed Cluster.')
param managedIdentityName string

@description('Tier of the AKS Managed Cluster. Use Paid for HA with multiple AZs.')
@allowed([
  'Free'
  'Paid'
])
param aksSkuTier string

@description('Suffix used in the DNS name of the AKS Managed Cluster.')
@minLength(6)
@maxLength(6)
param aksDnsSuffix string

@description('Version of the Kubernetes software used by AKS.')
param kubernetesVersion string

@description('Name of the Apps VNet where the AKS Managed Cluster will be deployed.')
param vnetName string

@description('Name of the Apps Subnet where the AKS Managed Cluster will be deployed.')
param subnetName string

@description('Enable auto scaling for AKS system node pool.')
param enableAutoScaling bool

@description('Minimum number of nodes in the AKS system node pool.')
param nodePoolMinCount int

@description('Maximum number of nodes in the AKS system node pool.')
param nodePoolMaxCount int

@description('VM size of every node in the AKS system node pool.')
param nodePoolVmSize string

@description('Enable encryption at AKS nodes.')
param enableEncryptionAtHost bool

@description('Create the AKS Managed Cluster as private cluster.')
param enablePrivateCluster bool

@description('Names of the VNets linked to the DNS Private Zone of AKS.')
param privateDnsZoneLinkedVNetNames array

@description('Enable Pod-Managed Identity feature on the AKS Managed Cluster.')
param enablePodManagedIdentity bool

@description('List of Pod Identities spec with name, namespace and Managed Identity name.')
@metadata({
  podIdentityName: 'Name of the Pod Identity.'
  podIdentityNamespace: 'Name where the Pod can use the Pod Identity.'
  managedIdentityName: 'Name of the application Managed Identity.'
  example: [
    {
      podIdentityName: 'merchant-view-podid'
      podIdentityNamespace: 'merchant-ns'
      managedIdentityName: 'BRS-MEX-USE2-CRECESDX-SWO-AD04'
    }
  ]
})
param podIdentities array = []

@description('Enable Workload Identity feature on the AKS Managed Cluster.')
param enableWorkloadIdentity bool

@description('Enable AKS Application Gateway Ingress Controller (AGIC) add-on.')
param enableAGICAddon bool

@description('Name of the Application Gateway managed by AGIC add-on.')
param appGatewayName string

@description('Create custom Route Table for Gateway Subnet managed by AKS (with kubenet network plugin).')
param createCustomRouteTable bool

@description('Enable Key Vault Secrets Provider add-on.')
param enableKeyVaultSecretsProviderAddon bool

@description('Enable rotation of Secrets by Key Vault Secrets Provider add-on.')
param enableSecretsRotation bool

@description('Poll interval for Secrets rotation by Key Vault Secrets Provider add-on.')
@allowed([ '2m', '5m', '10m', '30m' ])
param secrtsRotationPollInterval string

// ==================================== Diagnostics options ====================================

@description('Enable AKS OMS Agent add-on.')
param enableOMSAgentAddon bool

@description('Name of the Log Analytics Workspace managed by OMSAgent add-on.')
param workspaceName string

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on AKS Managed Cluster.')
param enableLock bool

// ==================================== PaaS Firewall settings ====================================

@description('Enable public access to the AKS Management Plane.')
param enablePublicAccess bool

// ==================================== Resources ====================================

// ==================================== AKS Managed Cluster ====================================

var aksDnsPrefix = 'azmxku1${aksDnsSuffix}'

var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-08-03-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-KU01'
  location: location
  sku: {
    name: 'Basic'
    tier: aksSkuTier
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksManagedIdentity.id}': {}
    }
  }
  properties: {
    dnsPrefix: aksDnsPrefix
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: [
      {
        name: 'agentpool1'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
        availabilityZones: [ '1', '2', '3' ]
        scaleSetPriority: 'Regular'
        enableAutoScaling: enableAutoScaling
        minCount: nodePoolMinCount
        maxCount: nodePoolMaxCount
        count: 1
        scaleDownMode: 'Delete'
        vmSize: nodePoolVmSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        osDiskSizeGB: 0
        osDiskType: 'Managed'
        enableEncryptionAtHost: enableEncryptionAtHost
        upgradeSettings: {
          maxSurge: '1'
        }
        tags: standardTags
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
      enablePrivateClusterPublicFQDN: enablePrivateCluster
      privateDNSZone: privateDnsZone.id
    }
    networkProfile: {
      networkPlugin: 'kubenet'
      networkPolicy: 'calico'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        enableMultipleStandardLoadBalancers: false
        managedOutboundIPs: {
          count: 1
        }
      }
      outboundType: 'loadBalancer'
      ipFamilies: [
        'IPv4'
      ]
    }
    autoUpgradeProfile: {
      upgradeChannel: 'none'
    }
    enableRBAC: true
    aadProfile: {
      enableAzureRBAC: true
      managed: true
    }
    disableLocalAccounts: true
    podIdentityProfile: {
      enabled: enablePodManagedIdentity
      userAssignedIdentities: podIdentitiesWithManagedIdentities
    }
    securityProfile: {
      workloadIdentity: {
        enabled: (enablePodManagedIdentity) ? false : enableWorkloadIdentity
      }
    }
    addonProfiles: {
      ingressApplicationGateway: {
        enabled: enableAGICAddon
        config: {
          applicationGatewayId: resourceId('Microsoft.Network/applicationGateways', appGatewayName)
        }
      }
      omsagent: {
        enabled: enableOMSAgentAddon
        config: {
          logAnalyticsWorkspaceResourceID: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: enableKeyVaultSecretsProviderAddon
        config: {
          enableSecretRotation: (enableSecretsRotation) ? 'true' : 'false'
          rotationPollInterval: secrtsRotationPollInterval
        }
      }
    }
    publicNetworkAccess: (enablePublicAccess) ? 'Enabled' : 'Disabled'
  }
  tags: standardTags
}

// ==================================== Custom Private DNS Zone ====================================

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${location}.azmk8s.io'
  location: 'global'
  properties: {
  }
  tags: standardTags
}

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (linkedVNetName, index) in privateDnsZoneLinkedVNetNames: {
  name: 'apiserver-NetworkLink${index}'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', linkedVNetName)
    }
  }
  tags: standardTags
}]

// ==================================== Custom Route Table ====================================

resource aksCustomRouteTable 'Microsoft.Network/routeTables@2022-05-01' = if (createCustomRouteTable) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-UD01'
  location: location
  properties: {
    routes: []
  }
  tags: standardTags
}

// ==================================== AKS Managed Identity ====================================

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

// ==================================== Apps Managed Identities ====================================

var podIdentitiesWithManagedIdentities = podIdentities

// ==================================== Resource Lock ====================================

resource aksLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL09'
  scope: aksCluster
  properties: {
    level: 'CanNotDelete'
    notes: 'AKS Managed Cluster should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the AKS Managed Cluster.')
output aksClusterId string = aksCluster.id

@description('URI of the Private Endpoint to access the AKS Management Plane.')
output managementPlanePrivateFQDN string = aksCluster.properties.privateFQDN

@description('Special URI for Azure Portal to access to the AKS Management Plane.')
output managementPlaneAzurePortalFQDN string = aksCluster.properties.azurePortalFQDN

@description('Name of the Node Resource Group where AKS managed resources are located.')
output aksNodeResourceGroupName string = aksCluster.properties.nodeResourceGroup

@description('Principal ID of the kubelet process in the AKS Managed Cluster.')
output aksKubeletPrincipalId string = aksCluster.properties.identityProfile.kubeletidentity.objectId

@description('Principal ID of the AGIC add-on in the AKS Managed Cluster.')
output aksAGICPrincipalId string = (enableAGICAddon) ? aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId : ''

@description('Principal ID of the Key Vault Secrets Provider add-on in the AKS Managed Cluster.')
output aksKeyVaultSecretsProviderPrincipalId string = (enableKeyVaultSecretsProviderAddon) ? aksCluster.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId : ''

@description('Client ID of the Key Vault Secrets Provider add-on in the AKS Managed Cluster.')
output aksKeyVaultSecretsProviderClientId string = (enableKeyVaultSecretsProviderAddon) ? aksCluster.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.clientId : ''

@description('Principal ID of the OMSAgent add-on in the AKS Managed Cluster.')
output aksOMSAgentPrincipalId string = (enableOMSAgentAddon) ? aksCluster.properties.addonProfiles.omsagent.identity.objectId : ''
