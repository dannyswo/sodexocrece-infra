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

@description('Name of the Applications VNet. Must be defined when enableNetwork is false.')
param appsVNetName string

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

@description('Private IP of the Application Data Storage Account\'s Private Endpoint.')
param appsDataStoragePEPrivateIPAddress string

@description('Private IP of the Azure SQL Database\'s Private Endpoint.')
param sqlDatabasePEPrivateIPAddress string

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

param appsDataStorageNameSuffix string
param appsDataStorageSkuName string
param appsDataStorageLogsRetentionDays int

param sqlServerNameSuffix string
@secure()
param sqlServerAdminLoginName string
@secure()
param sqlServerAdminLoginPassword string
param sqlDatabaseSkuType string
param sqlDatabaseSkuSize int
param sqlDatabaseMinCapacity int
param sqlDatabaseMaxSizeGB int
param sqlDatabaseZoneRedundant bool
param sqlDatabaseBackupRedundancy string
param sqlServerEnableAuditing bool
param sqlServerAuditLogsRetentionDays int
param sqlServerEnableThreatProtection bool
param sqlServerEnableVulnerabilityAssessments bool

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

module appsDataStorageModule '../modules/appsdatastorage.bicep' = {
  name: 'appsDataStorageModule'
  params: {
    location: location
    env: env
    storageAccountNameSuffix: appsDataStorageNameSuffix
    keyVaultUri: keyVaultModule.outputs.keyVaultUri
    storageAccountSkuName: appsDataStorageSkuName
    diagnosticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    logsRetentionDays: appsDataStorageLogsRetentionDays
    standardTags: standardTags
  }
}

module appsDataStoragePrivateEndpointModule '../modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'appsDataStoragePrivateEndpointModule'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE04'
    subnetName: selectedEndpointsSubnetName
    privateIPAddresses: [ appsDataStoragePEPrivateIPAddress ]
    serviceId: appsDataStorageModule.outputs.storageAccountId
    groupId: 'storageAccount'
    linkedVNetNames: selectedLinkedVNetNames
    standardTags: standardTags
  }
}

module sqlDatabaseModule '../modules/sqldatabase.bicep' = {
  name: 'sqlDatabaseModule'
  params: {
    location: location
    env: env
    sqlServerNameSuffix: sqlServerNameSuffix
    adminLoginName: sqlServerAdminLoginName
    adminLoginPassword: sqlServerAdminLoginPassword
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
    standardTags: standardTags
  }
}

module sqlDatabasePrivateEndpointModule '../modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'sqlDatabasePrivateEndpointModule'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE01'
    subnetName: selectedEndpointsSubnetName
    privateIPAddresses: [ sqlDatabasePEPrivateIPAddress ]
    serviceId: sqlDatabaseModule.outputs.sqlServerId
    groupId: 'sqlServer'
    linkedVNetNames: selectedLinkedVNetNames
    standardTags: standardTags
  }
}
