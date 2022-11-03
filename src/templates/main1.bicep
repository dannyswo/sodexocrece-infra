@description('Azure region to deploy the Private Endpoint.')
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
param gatewayVnetName string

@description('Name of the Gateway Subnet. Must be defined when enableNetwork is false.')
param gatewaySubnetName string

@description('Name of the Applications VNet. Must be defined when enableNetwork is false.')
param appsVnetName string

@description('Name of the Applications Subnet. Must be defined when enableNetwork is false.')
param appsSubnetName string

@description('Name of the Endpoints VNet. Must be defined when enableNetwork is false.')
param endpointsVnetName string

@description('Name of the Endpoints Subnet. Must be defined when enableNetwork is false.')
param endpointsSubnetName string

@description('Name of the Jump Servers VNet. Must be defined when enableNetwork is false.')
param jumpServersVnetName string

@description('Name of the DevOps Agents VNet. Must be defined when enableNetwork is false.')
param devopsAgentsVnetName string

@description('Create Private Endpoints for the required modules like keyvault, storage, database and acr.')
param enablePrivateEndpoints bool = true

@description('Private IP of the Key Vault\'s Private Endpoint.')
param keyVaultPEPrivateIPAddress string

@description('Private IP of the Storage Account\'s Private Endpoint.')
param dataStoragePEPrivateIPAddress string

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

param keyVaultNameSuffix string

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

param workspaceSkuName string
param workspaceLogRetentionDays int

param flowLogsRetentionDays int

param dataStorageNameSuffix string
param dataStorageSkuName string
param dataStorageLogsRetentionDays int

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

module networkModule 'modules/network1.bicep' = if (enableNetwork) {
  name: 'networkModule'
  params: {
    location: location
    env: env
    gatewayVNetName: 'VN01'
    gatewayVNetAddressPrefix: '10.169.90.0/24'
    gatewaySubnetName: 'SN01'
    gatewaySubnetAddressPrefix: '10.169.90.128/25'
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

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
    env: env
    keyVaultNameSuffix: keyVaultNameSuffix
    standardTags: standardTags
  }
}

var selectedEndpointsSubnetName = (enableNetwork) ? networkModule.outputs.subnets[2].name : endpointsSubnetName
var selectedLinkedVnetNames = (enableNetwork) ? [
  networkModule.outputs.vnets[0].name
  networkModule.outputs.vnets[1].name
  networkModule.outputs.vnets[2].name
] : [
  gatewayVnetName
  appsVnetName
  endpointsVnetName
  jumpServersVnetName
  devopsAgentsVnetName
]

module keyVaultPrivateEndpointModule 'modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'keyVaultPrivateEndpointModule'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE02'
    subnetName: selectedEndpointsSubnetName
    privateIPAddresses: [ keyVaultPEPrivateIPAddress ]
    serviceId: keyVaultModule.outputs.keyVaultId
    groupId: 'vault'
    linkedVnetNames: selectedLinkedVnetNames
    standardTags: standardTags
  }
}

var selectedGatewaySubnetName = (enableNetwork) ? networkModule.outputs.subnets[0].name : gatewaySubnetName

module appGatewayModule 'modules/agw.bicep' = {
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

module logAnalyticsModule 'modules/loganalytics.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    location: location
    env: env
    workspaceSkuName: workspaceSkuName
    logRetentionDays: workspaceLogRetentionDays
    standardTags: standardTags
  }
}

module networkWatcherModule 'modules/networkwatcher.bicep' = {
  name: 'networkWatcherModule'
  params: {
    location: location
    env: env
    targetNsgName: networkModule.outputs.appsNSGName
    targetWorkspaceName: logAnalyticsModule.outputs.workspaceName
    flowLogsRetentionDays: flowLogsRetentionDays
    standardTags: standardTags
  }
}

module dataStorageModule 'modules/datastorage.bicep' = {
  name: 'dataStorageModule'
  params: {
    location: location
    env: env
    dataStorageNameSuffix: dataStorageNameSuffix
    dataStorageSkuName: dataStorageSkuName
    keyVaultUri: keyVaultModule.outputs.keyVaultUri
    targetWorkspaceName: logAnalyticsModule.outputs.workspaceName
    logsRetentionDays: dataStorageLogsRetentionDays
    standardTags: standardTags
  }
}

module dataStoragePrivateEndpointModule 'modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'dataStoragePrivateEndpointModule'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE04'
    subnetName: selectedEndpointsSubnetName
    privateIPAddresses: [ dataStoragePEPrivateIPAddress ]
    serviceId: keyVaultModule.outputs.keyVaultId
    groupId: 'storageAccount'
    linkedVnetNames: selectedLinkedVnetNames
    standardTags: standardTags
  }
}

module acrModule 'modules/acr.bicep' = {
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

module acrPrivateEndpointModule 'modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'acrModulePrivateEndpoint'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE03'
    subnetName: selectedEndpointsSubnetName
    privateIPAddresses: acrPEPrivateIPAddresses
    serviceId: acrModule.outputs.registryId
    groupId: 'registry'
    linkedVnetNames: selectedLinkedVnetNames
    standardTags: standardTags
  }
}

var selectedAppsSubnetName = (enableNetwork) ? networkModule.outputs.subnets[1].name : appsSubnetName

module aksModule 'modules/aks.bicep' = {
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
    logAnalyticsWorkspaceName: ''
    standardTags: standardTags
  }
}
