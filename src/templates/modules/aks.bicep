@description('Azure region to deploy the AKS Managed Cluster.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param environment string

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
param kubernetesVersion string = '1.23.12'

@description('ID of the Subnet where the Cluster will be deployed.')
param subnetId string

@description('Enable auto scaling for AKS system node pool.')
param enableAutoScaling bool = false

@description('Minimum number of nodes in the AKS system node pool.')
param minCount int = 1

@description('Maximum number of nodes in the AKS system node pool.')
param maxCount int = 1

@description('VM size of every node in the AKS system node pool.')
param vmSize string = 'standard_d2s_v3'

@description('ID of the Application Gateway managed by AGIC add-on.')
param applicationGatewayId string

@description('ID of the Log Analytics Workspace managed by OMSAgent add-on.')
param logAnalyticsWorkspaceId string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-08-03-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-KU01'
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
        enableEncryptionAtHost: true
        upgradeSettings: {
          maxSurge: '1'
        }
        tags: resourceGroup().tags
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: true
      enablePrivateClusterPublicFQDN: false
      privateDNSZone: 'system'
    }
    networkProfile: {
      networkPlugin: 'kubenet'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        enableMultipleStandardLoadBalancers: false
      }
      outboundType: 'loadBalancer'
    }
    // autoUpgradeProfile: { }
    // podIdentityProfile: { }
    // ingressProfile: { }
    // workloadAutoScalerProfile: { }
    // securityProfile: { }
    // autoUpgradeProfile: { }
    // azureMonitorProfile: { }
    nodeResourceGroup: 'BRS-MEX-USE2-CRECESDX-${environment}-RG02'
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
  tags: resourceGroup().tags
}

resource aksLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-AL02'
  scope: aksCluster
  properties: {
    level: 'CanNotDelete'
    notes: 'AKS Managed Cluster should not be deleted.'
  }
}

output managementPlaneFQDN string = aksCluster.properties.fqdn
