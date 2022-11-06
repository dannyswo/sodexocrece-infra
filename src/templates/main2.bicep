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

// Private Endpoints properties

@description('Create Private Endpoints for the required modules like keyvault, appdatastorage, database and acr.')
param enablePrivateEndpoints bool = true

@description('Private IP of the Key Vault\'s Private Endpoint.')
param keyVaultPEPrivateIPAddress string

@description('Private IP of the Application Data Storage Account\'s Private Endpoint.')
param appsDataStoragePEPrivateIPAddress string

// Resource properties

param monitoringDataStorageNameSuffix string
param monitoringDataStorageSkuName string

param workspaceSkuName string
param workspaceCapacityReservation int
param workspaceLogRetentionDays int

param flowLogsRetentionDays int

param keyVaultNameSuffix string
param keyVaultEnablePurgeProtection bool
param keyVaultSoftDeleteRetentionDays int

param appGatewayNameSuffix string
param appGatewaySkuTier string
param appGatewaySkuName string
param appGatewayAutoScaleMinCapacity int
param appGatewayAutoScaleMaxCapacity int
param appGatewayEnableHttpPort bool
param appGatewayEnableHttpsPort bool
param appGatewayPublicCertificateId string

param appsDataStorageNameSuffix string
param appsDataStorageSkuName string

/*
param sqlServerNameSuffix string
@secure()
param sqlServerAdminUser string
@secure()
param sqlServerAdminPass string
param sqlDatabaseSkuType string
param sqlDatabaseSkuSize int
param sqlDatabaseMinCapacity int
param sqlDatabaseMaxSizeGB int
param sqlDatabaseZoneRedundant bool
param sqlDatabaseBackupRedundancy string
*/

param acrNameSuffix string
param acrSku string
param acrZoneRedundancy string
param acrUntaggedRetentionDays int
param acrSoftDeleteRetentionDays int

// Diagnostics options

param keyVaultEnableDiagnostics bool
param keyVaultLogsRetentionDays int

param appGatewayEnableDiagnostics bool
param appGatewayLogsRetentionDays int

param appsDataStorageEnableDiagnostics bool
param appsDataStorageLogsRetentionDays int

//param sqlServerEnableAuditing bool
//param sqlServerAuditLogsRetentionDays int
//param sqlServerEnableThreatProtection bool
//param sqlServerEnableVulnerabilityAssessments bool

param acrEnableDiagnostics bool
param acrLogsRetentionDays int

// Resource Locks switches

param monitoringDataStorageEnableLock bool
param workspaceEnableLock bool
param networkWatcherEnableLock bool
param keyVaultEnableLock bool
param appGatewayEnableLock bool
param appsDataStorageEnableLock bool
//param sqlDatabaseEnableLock bool
param acrEnableLock bool

// Firewall settings

param keyVaultAllowedSubnetNames array
param keyVaultAllowedIPsOrCIDRs array

param appsDataStorageAllowedSubnetNames array
param appsDataStorageAllowedIPsOrCIDRs array

//param sqlServerAllowedIPRanges array

param acrAllowedIPsOrCIDRs array

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

module monitoringDataStorageModule 'modules/monitoringdatastorage.bicep' = {
  name: 'monitoringDataStorageModule'
  params: {
    location: location
    env: env
    storageAccountNameSuffix: monitoringDataStorageNameSuffix
    storageAccountSkuName: monitoringDataStorageSkuName
    enableLock: monitoringDataStorageEnableLock
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
    enableLock: workspaceEnableLock
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
    enableLock: networkWatcherEnableLock
    standardTags: standardTags
  }
}

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
    env: env
    keyVaultNameSuffix: keyVaultNameSuffix
    enablePurgeProtection: keyVaultEnablePurgeProtection
    softDeleteRetentionDays: keyVaultSoftDeleteRetentionDays
    enableDiagnostics: keyVaultEnableDiagnostics
    diagnosticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    logsRetentionDays: keyVaultLogsRetentionDays
    enableLock: keyVaultEnableLock
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
    appsDataStorageEncryptionKeyName: 'crececonsdx-files-key4'
    encryptionKeysIssueDateTime: '11/5/2023 11:30:00 PM'
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

module appGatewayModule 'modules/agw.bicep' = {
  name: 'appGatewayModule'
  params: {
    location: location
    env: env
    managedIdentityName: managedIdentitiesModule.outputs.appGatewayManagedIdentityName
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
    enableLock: appGatewayEnableLock
    standardTags: standardTags
  }
}

module appsDataStorageModule 'modules/appsdatastorage.bicep' = {
  name: 'appsDataStorageModule'
  params: {
    location: location
    env: env
    managedIdentityName: managedIdentitiesModule.outputs.appsDataStorageManagedIdentityName
    storageAccountNameSuffix: appsDataStorageNameSuffix
    storageAccountSkuName: appsDataStorageSkuName
    encryptionKeyName: keyVaultObjectsModule.outputs.appsDataStorageEncryptionKeyName
    keyVaultUri: keyVaultModule.outputs.keyVaultUri
    enableDiagnostics: appsDataStorageEnableDiagnostics
    diagnosticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    logsRetentionDays: appsDataStorageLogsRetentionDays
    enableLock: appsDataStorageEnableLock
    allowedSubnetNames: appsDataStorageAllowedSubnetNames
    allowedIPsOrCIDRs: appsDataStorageAllowedIPsOrCIDRs
    standardTags: standardTags
  }
}

module appsDataStoragePrivateEndpointModule 'modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'appsDataStoragePrivateEndpointModule'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE04'
    vnetName: selectedNetworkNames.endpointsVNetName
    subnetName: selectedNetworkNames.endpointsSubnetName
    privateIPAddresses: [ appsDataStoragePEPrivateIPAddress ]
    serviceId: appsDataStorageModule.outputs.storageAccountId
    groupId: 'blob'
    linkedVNetNames: selectedLinkedVNetNames
    standardTags: standardTags
  }
}

/*
module sqlDatabaseModule 'modules/sqldatabase.bicep' = {
  name: 'sqlDatabaseModule'
  params: {
    location: location
    env: env
    sqlServerNameSuffix: sqlServerNameSuffix
    adminUser: sqlServerAdminUser
    adminPass: sqlServerAdminPass
    skuType: sqlDatabaseSkuType
    skuSize: sqlDatabaseSkuSize
    minCapacity: sqlDatabaseMinCapacity
    maxSizeGB: sqlDatabaseMaxSizeGB
    zoneRedundant: sqlDatabaseZoneRedundant
    backupRedundancy: sqlDatabaseBackupRedundancy
    enableAuditing: sqlServerEnableAuditing
    auditStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
    auditLogsRetentionDays: sqlServerAuditLogsRetentionDays
    enableThreatProtection: sqlServerEnableThreatProtection
    enableVulnerabilityAssessments: sqlServerEnableVulnerabilityAssessments
    assessmentsStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
    enableLock: sqlDatabaseEnableLock
    allowedIPRanges: sqlServerAllowedIPRanges
    standardTags: standardTags
  }
}
*/

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
    enableDiagnostics: acrEnableDiagnostics
    diagnosticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    logsRetentionDays: acrLogsRetentionDays
    enableLock: acrEnableLock
    allowedIPsOrCIDRs: acrAllowedIPsOrCIDRs
    standardTags: standardTags
  }
}
