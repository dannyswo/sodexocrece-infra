@description('Azure region to deploy the Private Endpoint.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param environment string

@description('Create network resources defined in the network module.')
param enableNetwork bool = false

@description('ID of the Endpoints Subnet. Must be defined when enableNetwork is false.')
param endpointsSubnetId string

@description('ID of the Applications Subnet. Must be defined when enableNetwork is false.')
param appsSubnetId string

@description('Create Private Endpoints for the required modules like keyvault, storage, database and acr.')
param enablePrivateEndpoints bool = true

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

param keyVaultNameSuffix string

param acrNameSuffix string
param acrSku string
param acrZoneRedundancy string
param acrUntaggedRetentionDays int
param acrSoftDeleteRetentionDays int

param aksSkuTier string
param aksDnsSuffix string
param aksKubernetesVersion string
param aksEnableAutoScaling bool
param aksNodePoolMinCount int
param aksNodePoolMaxCount int
param aksNodePoolVmSize string

module networkModule 'modules/network1.bicep' = if (enableNetwork) {
  name: 'networkModule'
  params: {
    location: location
    environment: environment
    gatewayVNetName: 'VN01'
    gatewaySubnetAddressPrefix: '10.169.90.0/24'
    gatewaySubnetName: 'SN01'
    gatewayVNetAddressPrefix: '10.169.90.128/25'
    appsVNetName: 'VN02'
    appsVNetAddressPrefix: '10.169.72.0/21'
    appsSubnetName: 'SN02'
    appsSubnetAddressPrefix: '10.169.72.64/27'
    endpointsVNetName: 'VN03'
    endpointsVNetAddressPrefix: '10.169.88.0/23'
    endpointsSubnetName: 'SN03'
    endpointsSubnetAddressPrefix: '10.169.88.64/26'
    standardTags: standardTags
  }
}

var selectedEndpointsSubnetId = (enableNetwork) ? networkModule.outputs.subnets[2].id : endpointsSubnetId

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
    environment: environment
    keyVaultNameSuffix: keyVaultNameSuffix
    standardTags: standardTags
  }
}

module keyVaultPrivateEndpointModule 'modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'keyVaultPrivateEndpointModule'
  params: {
    location: location
    environment: environment
    privateEndpointName: 'PE02'
    subnetId: selectedEndpointsSubnetId
    privateEndpointIPAddress: '10.169.88.69'
    serviceId: keyVaultModule.outputs.keyVaultId
    groupId: 'vault'
    standardTags: standardTags
  }
}

module acrModule 'modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    location: location
    environment: environment
    acrNameSuffix: acrNameSuffix
    acrSku: acrSku
    zoneRedundancy: acrZoneRedundancy
    untaggedRetentionDays: acrUntaggedRetentionDays
    softDeleteRetentionDays: acrSoftDeleteRetentionDays
    standardTags: standardTags
  }
}

module acrModulePrivateEndpoint 'modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'acrModulePrivateEndpoint'
  params: {
    location: location
    environment: environment
    privateEndpointName: 'PE03'
    subnetId: selectedEndpointsSubnetId
    privateEndpointIPAddress: '10.169.88.72'
    serviceId: acrModule.outputs.registryId
    groupId: 'registry'
    standardTags: standardTags
  }
}

var selectedAppsSubnetId = (enableNetwork) ? networkModule.outputs.subnets[1].id : appsSubnetId

module aksModule 'modules/aks.bicep' = {
  name: 'aksModule'
  params: {
    location: location
    environment: environment
    aksSkuTier: aksSkuTier
    aksDnsSuffix: aksDnsSuffix
    kubernetesVersion: aksKubernetesVersion
    subnetId: selectedAppsSubnetId
    enableAutoScaling: aksEnableAutoScaling
    minCount: aksNodePoolMinCount
    maxCount: aksNodePoolMaxCount
    vmSize: aksNodePoolVmSize
    applicationGatewayId: ''
    logAnalyticsWorkspaceId: ''
    standardTags: standardTags
  }
}
