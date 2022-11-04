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

@description('Create network resources defined in the network module.')
param enableNetwork bool = false

@description('Name of the Gateway VNet. Must be defined when enableNetwork is false.')
param gatewayVNetName string

@description('Name of the Gateway Subnet. Must be defined when enableNetwork is false.')
param gatewaySubnetName string

@description('Name of the Applications VNet. Must be defined when enableNetwork is false.')
param appsVNetName string

@description('Name of the Applications Subnet. Must be defined when enableNetwork is false.')
param appsSubnetName string

@description('Name of the Endpoints VNet. Must be defined when enableNetwork is false.')
param endpointsVNetName string

@description('Name of the Endpoints Subnet. Must be defined when enableNetwork is false.')
param endpointsSubnetName string

@description('Name of the Jump Servers VNet. Must be defined when enableNetwork is false.')
param jumpServersVNetName string

@description('Name of the DevOps Agents VNet. Must be defined when enableNetwork is false.')
param devopsAgentsVNetName string

@description('Create Private Endpoints for the required modules like keyvault, appdatastorage, database and acr.')
param enablePrivateEndpoints bool = true

@description('Private IPs of the Container Registry\'s Private Endpoint.')
param acrPEPrivateIPAddresses array

@description('Standard tags applied to all resources.')
@metadata({
  ApplicationName: ''
  ApplicationOwner: ''
  ApplicationSponsor: ''
  TechnicalContact: ''
  Billing: ''
  Maintenance: ''
  EnvironmentType: ''
  Security: ''
  DeploymentDate: ''
  dd_organization: ''
})
param standardTags object = resourceGroup().tags

param appGatewayNameSuffix string
param appGatewaySkuTier string
param appGatewaySkuName string
param appGatewaySkuCapacity int
param appGatewayEnablePublicIP bool
param appGatewayPrivateIPAddress string
param appGatewayAutoScaleMinCapacity int
param appGatewayAutoScaleMaxCapacity int
param appGatewayEnablePublicCertificate bool
param appGatewayPublicCertificateId string

param acrNameSuffix string
param acrSku string
param acrZoneRedundancy string
param acrUntaggedRetentionDays int
param acrSoftDeleteRetentionDays int

param aksSkuTier string
param aksDnsSuffix string
param aksKubernetesVersion string
param aksNodeResourceGroupName string
param aksEnableAutoScaling bool
param aksNodePoolMinCount int
param aksNodePoolMaxCount int
param aksNodePoolVmSize string
param aksEnableEncryptionAtHost bool

var selectedGatewaySubnetName = gatewaySubnetName

module appGatewayModule '../modules/agw.bicep' = {
  name: 'appGatewayModule'
  params: {
    location: location
    env: env
    appGatewayNameSuffix: appGatewayNameSuffix
    appGatewaySkuTier: appGatewaySkuTier
    appGatewaySkuName: appGatewaySkuName
    appGatewaySkuCapacity: appGatewaySkuCapacity
    enablePublicIP: appGatewayEnablePublicIP
    appGatewayPrivateIPAddress: appGatewayPrivateIPAddress
    gatewaySubnetName: selectedGatewaySubnetName
    autoScaleMinCapacity: appGatewayAutoScaleMinCapacity
    autoScaleMaxCapacity: appGatewayAutoScaleMaxCapacity
    enablePublicCertificate: appGatewayEnablePublicCertificate
    publicCertificateId: appGatewayPublicCertificateId
    standardTags: standardTags
  }
}

module acrModule '../modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    location: location
    env: env
    acrNameSuffix: acrNameSuffix
    acrSku: acrSku
    zoneRedundancy: acrZoneRedundancy
    untaggedRetentionDays: acrUntaggedRetentionDays
    softDeleteRetentionDays: acrSoftDeleteRetentionDays
    standardTags: standardTags
  }
}

var selectedEndpointsSubnetName = endpointsSubnetName
var selectedLinkedVNetNames = (enableNetwork) ? [
  gatewayVNetName
  appsVNetName
  endpointsVNetName
] : [
  gatewayVNetName
  appsVNetName
  endpointsVNetName
  jumpServersVNetName
  devopsAgentsVNetName
]

module acrPrivateEndpointModule '../modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'acrModulePrivateEndpoint'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE03'
    subnetName: selectedEndpointsSubnetName
    privateIPAddresses: acrPEPrivateIPAddresses
    serviceId: acrModule.outputs.registryId
    groupId: 'registry'
    linkedVNetNames: selectedLinkedVNetNames
    standardTags: standardTags
  }
}

var selectedAppsSubnetName = appsSubnetName

module aksModule '../modules/aks.bicep' = {
  name: 'aksModule'
  params: {
    location: location
    env: env
    aksSkuTier: aksSkuTier
    aksDnsSuffix: aksDnsSuffix
    kubernetesVersion: aksKubernetesVersion
    nodeResourceGroupName: aksNodeResourceGroupName
    subnetName: selectedAppsSubnetName
    enableAutoScaling: aksEnableAutoScaling
    minCount: aksNodePoolMinCount
    maxCount: aksNodePoolMaxCount
    vmSize: aksNodePoolVmSize
    enableEncryptionAtHost: aksEnableEncryptionAtHost
    applicationGatewayName: appGatewayModule.outputs.applicationGatewayName
    logAnalyticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    standardTags: standardTags
  }
}
