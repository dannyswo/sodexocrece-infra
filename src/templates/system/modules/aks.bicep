/**
 * Module: aks
 * Depends on: inframanagedids, network1 (optional), agw, monitoringworkspace
 * Used by: system/mainSystem
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

@description('ID of the AAD Tenant used to register new custom Role Definitions.')
param tenantId string = subscription().tenantId

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

@description('Enable Workload Identity feature on the AKS Managed Cluster.')
param enableWorkloadIdentity bool

@description('Enable AKS Application Gateway Ingress Controller Add-on.')
param enableAGICAddon bool

@description('Name of the Application Gateway managed by AGIC add-on.')
param appGatewayName string

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
param podIdentities array

// ==================================== Diagnostics options ====================================

@description('Enable AKS OMS Agents Add-on.')
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
      '${managedIdentity.id}': {}
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
  name: '${aksDnsPrefix}-NetworkLink${index}'
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

// ==================================== AKS Managed Identity ====================================

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

// ==================================== Role Assignments ====================================

@description('Role Definition IDs for AKS to ACR communication.')
var aksAcrRoleDefinitions = [
  {
    roleName: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    roleDescription: 'AcrPull | acr pull'
    roleAssignmentDescription: 'Pull container images from ACR in AKS.'
  }
]

resource aksAcrRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAcrRoleDefinitions: {
  name: guid(resourceGroup().id, aksCluster.id, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

@description('Role Definition IDs for AKS to App Gateway communication (RG scope).')
var aksAppGatewayRoleDefinitions1 = [
  {
    roleName: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    roleDescription: 'Reader | View all resources, but does not allow you to make any changes'
    roleAssignmentDescription: 'View and list resources from Resource Group where AKS Managed Cluster is deployed.'
  }
  {
    roleName: 'f1a07417-d97a-45cb-824c-7a7467783830'
    roleDescription: 'Managed Identity Operator | Read and Assign User Assigned Identity'
    roleAssignmentDescription: 'View and change Managed Identities from AGIC AKS Add-on.'
  }
]

resource aksAppGatewayRoleAssignments1 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions1: {
  name: guid(resourceGroup().id, aksCluster.id, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

resource appGateway 'Microsoft.Network/applicationGateways@2022-05-01' existing = {
  name: appGatewayName
}

@description('Role Definition IDs for AKS to App Gateway communication (AGW scope).')
var aksAppGatewayRoleDefinitions2 = [
  {
    roleName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    roleDescription: 'Contributor | Grants full access to manage all resources'
    roleAssignmentDescription: 'Manage Application Gateway from AGIC AKS Add-on.'
  }
  {
    roleName: appGatewayAdminRoleDefinition.name
    roleDescription: 'Application Gateway Administrator | View and edit properties of an Application Gateway.'
    roleAssignmentDescription: 'Manage Application Gateway from AGIC AKS Add-on.'
  }
]

resource aksAppGatewayRoleAssignments2 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions2: {
  name: guid(resourceGroup().id, aksCluster.id, roleDefinition.roleName)
  scope: appGateway
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Custom Role Definitions ====================================

var appGatewayAdminActions = [
  'Microsoft.Network/applicationGateways/read'
  'Microsoft.Network/applicationGateways/write'
  'Microsoft.Network/applicationGateways/getMigrationStatus/action'
  'Microsoft.Network/applicationGateways/effectiveNetworkSecurityGroups/action'
  'Microsoft.Network/applicationGateways/effectiveRouteTable/action'
  'Microsoft.Network/applicationGateways/backendAddressPools/join/action'
  'Microsoft.Network/applicationGateways/providers/Microsoft.Insights/metricDefinitions/read'
  'Microsoft.Network/applicationGateways/providers/Microsoft.Insights/logDefinitions/read'
  'Microsoft.Network/applicationGateways/privateLinkResources/read'
  'Microsoft.Network/applicationGateways/privateLinkConfigurations/read'
  'Microsoft.Network/applicationGateways/privateEndpointConnections/write'
  'Microsoft.Network/applicationGateways/privateEndpointConnections/read'
  'Microsoft.Network/applicationGateways/restart/action'
  'Microsoft.Network/applicationGateways/stop/action'
  'Microsoft.Network/applicationGateways/start/action'
  'Microsoft.Network/applicationGateways/resolvePrivateLinkServiceId/action'
  'Microsoft.Network/applicationGateways/getBackendHealthOnDemand/action'
  'Microsoft.Network/applicationGateways/backendhealth/action'
]

var appGatewayAdminRoleName = 'Application Gateway Administrator'

resource appGatewayAdminRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(tenantId, resourceGroup().id, aksCluster.id, appGatewayAdminRoleName)
  properties: {
    roleName: appGatewayAdminRoleName
    description: 'View and edit properties of an Application Gateway.'
    type: 'customRole'
    permissions: [
      {
        actions: appGatewayAdminActions
        notActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

// ==================================== Apps Managed Identities ====================================

var podIdentitiesWithManagedIdentities = []

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

@description('URI of the Private Endpoint to access the AKS Management Plane.')
output managementPlanePrivateFQDN string = aksCluster.properties.privateFQDN

@description('Special URI for Azure Portal to access to the AKS Management Plane.')
output managementPlaneAzurePortalFQDN string = aksCluster.properties.azurePortalFQDN
