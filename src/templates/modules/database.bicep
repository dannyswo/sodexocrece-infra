@secure()
param administratorLogin string = ''
@secure()
param administratorLoginPassword string = ''
param administrators object = {
}
param collation string
param databaseName string
param sku object = {
  name: 'Standard'
  tier: 'Standard'
}
param location string = 'eastus2'
param maxSizeBytes int
param serverName string
param zoneRedundant bool = false
param licenseType string = 'LicenseIncluded'
param numberOfReplicas int = 0
param minCapacity int = 20000
param autoPauseDelay int = -1
param databaseTags object = {
}
param serverTags object = {
}

@description('To enable vulnerability assessments, the user deploying this template must have an administrator or owner permissions.')
param publicNetworkAccess string = 'Disabled'
param requestedBackupStorageRedundancy string = 'Local'

@description('resource id of a user assigned identity to be used by default.')
param minimalTlsVersion string = '1.2'
param connectionType string = 'Default'
param randomString string
param randomNumber string
param environment string = 'DEV'

var businessLine = 'BRS'
var businessRegion = 'LATAM'
var cloudRegion = 'USE2'
var projectName = 'CRECESDX'
var cloudProviderServer = 'az'
var cloudRegionServer = 'mx'
var cloudServiceServer = 'ku'

resource server 'Microsoft.Sql/servers@2021-11-01' = {
  location: location
  tags: serverTags
  name: '${cloudProviderServer}${cloudRegionServer}${cloudServiceServer}1${randomString}${randomNumber}'
  properties: {
    version: '12.0'
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: publicNetworkAccess
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    administrators: administrators
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource serverName_database 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: server
  location: location
  tags: databaseTags
  name: '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}-DB01'
  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
    zoneRedundant: zoneRedundant
    licenseType: licenseType
    highAvailabilityReplicaCount: numberOfReplicas
    minCapacity: minCapacity
    autoPauseDelay: autoPauseDelay
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
  }
  sku: sku
}

resource serverName_Default 'Microsoft.Sql/servers/connectionPolicies@2021-11-01' = {
  parent: server
  name: 'Default'
  properties: {
    connectionType: connectionType
  }
}
