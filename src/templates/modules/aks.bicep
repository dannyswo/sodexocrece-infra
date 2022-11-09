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

@description('Name of the Resource Group of the AKS managed resources (VMSS, LB, etc).')
param nodeResourceGroupName string

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

@description('Enable AKS Application Gateway Ingress Controller Add-on.')
param enableAGICAddon bool

@description('Name of the Application Gateway managed by AGIC add-on.')
param appGatewayName string

@description('Enable AKS OMS Agents Add-on.')
param enableOMSAgentAddon bool

@description('Name of the Log Analytics Workspace managed by OMSAgent add-on.')
param workspaceName string

@description('Enable Resource Lock on AKS Managed Cluster.')
param enableLock bool

@description('Enable public access to the AKS Management Plane.')
param enablePublicAccess bool

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource definitions ====================================

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

var aksDnsPrefix = 'azmxku1${aksDnsSuffix}'

var selectedNodeResourceGroupName = (env == 'SWO') ? nodeResourceGroupName : 'BRS-MEX-USE2-CRECESDX-${env}-RG02'

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
    nodeResourceGroup: selectedNodeResourceGroupName
    agentPoolProfiles: [
      {
        name: 'nodepool1'
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
    // autoUpgradeProfile: { }
    // podIdentityProfile: { }
    // ingressProfile: { }
    // workloadAutoScalerProfile: { }
    // securityProfile: { }
    // autoUpgradeProfile: { }
    // azureMonitorProfile: { }
    enableRBAC: true
    aadProfile: {
      enableAzureRBAC: true
      managed: true
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

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${aksDnsPrefix}.privatelink.eastus2.azmk8s.io'
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
}]

resource aksLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL09'
  scope: aksCluster
  properties: {
    level: 'CanNotDelete'
    notes: 'AKS Managed Cluster should not be deleted.'
  }
}

@description('URI of the Private Endpoint to access the AKS Management Plane.')
output managementPlanePrivateFQDN string = aksCluster.properties.privateFQDN

@description('Special URI for Azure Portal to access to the AKS Management Plane.')
output managementPlaneAzurePortalFQDN string = aksCluster.properties.azurePortalFQDN
