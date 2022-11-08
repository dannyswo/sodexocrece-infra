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

@description('Name of the Application Gateway managed by AGIC add-on.')
param appGatewayName string

@description('Name of the Log Analytics Workspace managed by OMSAgent add-on.')
param workspaceName string

@description('Enable Resource Lock on AKS Managed Cluster.')
param enableLock bool

@description('Standards tags applied to all resources.')
param standardTags object

// Resource definitions

var selectedNodeResourceGroupName = (env == 'SWO') ? nodeResourceGroupName : 'BRS-MEX-USE2-CRECESDX-${env}-RG02'

var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

var enableAGICAddon = false
var appGatewayId = resourceId('Microsoft.Network/applicationGateways', appGatewayName)

var enableOMSAgentAddon = false
var workspaceId = resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-08-03-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-KU01'
  location: location
  sku: {
    name: 'Basic'
    tier: aksSkuTier
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'azmxku1${aksDnsSuffix}'
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
      enablePrivateCluster: true
      enablePrivateClusterPublicFQDN: false
      privateDNSZone: 'system'
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
          applicationGatewayId: appGatewayId
        }
      }
      omsagent: {
        enabled: enableOMSAgentAddon
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
    }
    publicNetworkAccess: 'Disabled'
  }
  tags: standardTags
}

resource aksLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL09'
  scope: aksCluster
  properties: {
    level: 'CanNotDelete'
    notes: 'AKS Managed Cluster should not be deleted.'
  }
}

@description('URI for private access to the AKS Management Plane.')
output managementPlanePrivateFQDN string = aksCluster.properties.privateFQDN

@description('URI for public access to the AKS Management Plane.')
output managementPlanePublicFQDN string = aksCluster.properties.azurePortalFQDN
