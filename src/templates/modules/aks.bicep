@description('Azure region to deploy the AKS Managed Cluster.')
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

@description('Name of the Subnet where the Cluster will be deployed.')
param subnetName string

@description('Enable auto scaling for AKS system node pool.')
param enableAutoScaling bool

@description('Minimum number of nodes in the AKS system node pool.')
param minCount int

@description('Maximum number of nodes in the AKS system node pool.')
param maxCount int

@description('VM size of every node in the AKS system node pool.')
param vmSize string

@description('Enable encryption at AKS nodes.')
param enableEncryptionAtHost bool

@description('Name of the Application Gateway managed by AGIC add-on.')
param applicationGatewayName string

@description('Name of the Log Analytics Workspace managed by OMSAgent add-on.')
param logAnalyticsWorkspaceName string

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var selectedNodeResourceGroupName = (env == 'SWO') ? nodeResourceGroupName : 'BRS-MEX-USE2-CRECESDX-${env}-RG02'
var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', subnetName)
var applicationGatewayId = resourceId('Microsoft.Network/applicationGateways', applicationGatewayName)
var logAnalyticsWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)

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
        minCount: minCount
        maxCount: maxCount
        count: 1
        scaleDownMode: 'Delete'
        vmSize: vmSize
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
      networkPluginMode: 'Overlay'
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
    /*
    addonProfiles: {
      ingressApplicationGateway: {
        enabled: true
        config: {
          applicationGatewayId: applicationGatewayId
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
    */
    publicNetworkAccess: 'Disabled'
  }
  tags: standardTags
}

resource aksLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AL05'
  scope: aksCluster
  properties: {
    level: 'CanNotDelete'
    notes: 'AKS Managed Cluster should not be deleted.'
  }
}

output managementPlanePrivateFQDN string = aksCluster.properties.privateFQDN
output managementPlanePublicFQDN string = aksCluster.properties.azurePortalFQDN
