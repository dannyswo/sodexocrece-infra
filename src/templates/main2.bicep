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

// Network settings

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

@description('Name of the NSG attached to Applications Subnet. Must be defined when enableNetwork is false.')
param appsNSGName string

@description('Create Private Endpoints for the required modules like keyvault, appdatastorage, database and acr.')
param enablePrivateEndpoints bool = true

@description('Private IP of the Key Vault\'s Private Endpoint.')
param keyVaultPEPrivateIPAddress string

// Resource settings

param keyVaultNameSuffix string

param monitoringDataStorageNameSuffix string
param monitoringDataStorageSkuName string

param workspaceSkuName string
param workspaceCapacityReservation int
param workspaceLogRetentionDays int

param flowLogsRetentionDays int

param appGatewayNameSuffix string
param appGatewaySkuTier string
param appGatewaySkuName string
param appGatewayAutoScaleMinCapacity int
param appGatewayAutoScaleMaxCapacity int
param appGatewayEnableHttpPort bool
param appGatewayEnableHttpsPort bool
param appGatewayPublicCertificateId string
param appGatewayEnableDiagnostics bool
param appGatewayLogsRetentionDays int

param appsDataStorageNameSuffix string
param appsDataStorageSkuName string
param appsDataStorageEnableDiagnostics bool
param appsDataStorageLogsRetentionDays int

// Firewall settings

param keyVaultAllowedSubnetNames array
param keyVaultAllowedIPsOrCIDRs array

// Tags

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

// Resource definitions

module managedIdentitiesModule 'modules/managedids.bicep' = {
  name: 'managedIdsModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
  }
}

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

var selectedNetworkNames = (enableNetwork) ? {
  gatewayVNetName: networkModule.outputs.vnets[0].name
  gatewaySubnetName: networkModule.outputs.subnets[0].name
  appsVNetName: networkModule.outputs.vnets[1].name
  appsSubnetName: networkModule.outputs.subnets[1].name
  endpointsVNetName: networkModule.outputs.vnets[2].name
  endpointsSubnetName: networkModule.outputs.subnets[2].name
} : {
  gatewayVNetName: gatewayVNetName
  gatewaySubnetName: gatewaySubnetName
  appsVNetName: appsVNetName
  appsSubnetName: appsSubnetName
  endpointsVNetName: endpointsVNetName
  endpointsSubnetName: endpointsSubnetName
}

var selectedLinkedVNetNames = (enableNetwork) ? [
  networkModule.outputs.vnets[0].name
  networkModule.outputs.vnets[1].name
  networkModule.outputs.vnets[2].name
] : [
  gatewayVNetName
  appsVNetName
  endpointsVNetName
  jumpServersVNetName
  devopsAgentsVNetName
]

var selectedNSGNames = (enableNetwork) ? {
  appsNSGName: networkModule.outputs.appsNSGName
} : {
  appsNSGName: appsNSGName
}

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
    env: env
    keyVaultNameSuffix: keyVaultNameSuffix
    allowedSubnetNames: keyVaultAllowedSubnetNames
    allowedIPsOrCIDRs: keyVaultAllowedIPsOrCIDRs
    standardTags: standardTags
  }
}

module keyVaultPrivateEndpointModule 'modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'keyVaultPrivateEndpointModule'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE02'
    vnetName: selectedNetworkNames.endpointsVNetName
    subnetName: selectedNetworkNames.endpointsSubnetName
    privateIPAddresses: [ keyVaultPEPrivateIPAddress ]
    serviceId: keyVaultModule.outputs.keyVaultId
    groupId: 'vault'
    linkedVNetNames: selectedLinkedVNetNames
    standardTags: standardTags
  }
}

module keyVaultObjectsModule 'modules/keyvaultobjects.bicep' = {
  name: 'keyVaultObjectsModule'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    createEncryptionKeys: true
    appsDataStorageEncryptionKeyName: 'merchant-files-key'
    createEmptySecrets: false
    sqlDatabaseAdminUserSecretName: 'merchant-admin-user'
    sqlDatabaseAdminPassSecretName: 'merchant-admin-password'
  }
}

module keyVaultPoliciesModule 'modules/keyvaultpolicies.bicep' = {
  name: 'keyVaultPoliciesModule'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    appGatewayPrincipalId: managedIdentitiesModule.outputs.appGatewayManagedIdentityId
    appsDataStorageAccountPrincipalId: managedIdentitiesModule.outputs.appsDataStorageManagedIdentityId
  }
}

module monitoringDataStorageModule 'modules/monitoringdatastorage.bicep' = {
  name: 'monitoringDataStorageModule'
  params: {
    location: location
    env: env
    storageAccountNameSuffix: monitoringDataStorageNameSuffix
    storageAccountSkuName: monitoringDataStorageSkuName
    standardTags: standardTags
  }
}

module logAnalyticsModule 'modules/loganalytics.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    location: location
    env: env
    workspaceSkuName: workspaceSkuName
    workspaceCapacityReservation: workspaceCapacityReservation
    logRetentionDays: workspaceLogRetentionDays
    linkedStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
    standardTags: standardTags
  }
}

module networkWatcherModule 'modules/networkwatcher.bicep' = {
  name: 'networkWatcherModule'
  params: {
    location: location
    env: env
    targetNSGName: selectedNSGNames.appsNSGName
    flowLogsStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
    flowAnalyticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    flowLogsRetentionDays: flowLogsRetentionDays
    standardTags: standardTags
  }
}

module appGatewayModule 'modules/agw.bicep' = {
  name: 'appGatewayModule'
  params: {
    location: location
    env: env
    appGatewayNameSuffix: appGatewayNameSuffix
    appGatewaySkuTier: appGatewaySkuTier
    appGatewaySkuName: appGatewaySkuName
    gatewayVNetName: selectedNetworkNames.gatewayVNetName
    gatewaySubnetName: selectedNetworkNames.gatewaySubnetName
    autoScaleMinCapacity: appGatewayAutoScaleMinCapacity
    autoScaleMaxCapacity: appGatewayAutoScaleMaxCapacity
    enableHttpPort: appGatewayEnableHttpPort
    enableHttpsPort: appGatewayEnableHttpsPort
    publicCertificateId: appGatewayPublicCertificateId
    enableDiagnostics: appGatewayEnableDiagnostics
    diagnosticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    logsRetentionDays: appGatewayLogsRetentionDays
    managedIdentityName: managedIdentitiesModule.outputs.appGatewayManagedIdentityName
    standardTags: standardTags
  }
}

module appsDataStorageModule 'modules/appsdatastorage.bicep' = {
  name: 'appsDataStorageModule'
  params: {
    location: location
    env: env
    storageAccountNameSuffix: appsDataStorageNameSuffix
    storageAccountSkuName: appsDataStorageSkuName
    encryptionKeyName: keyVaultObjectsModule.outputs.appsDataStorageEncryptionKeyName
    keyVaultUri: keyVaultModule.outputs.keyVaultUri
    enableDiagnostics: appsDataStorageEnableDiagnostics
    diagnosticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    logsRetentionDays: appsDataStorageLogsRetentionDays
    managedIdentityName: managedIdentitiesModule.outputs.appsDataStorageManagedIdentityName
    standardTags: standardTags
  }
}
