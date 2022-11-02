@secure()
param administratorLogin string = ''
@secure()
param administratorLoginPassword string = ''
param administrators object = {
}
param collation string
param sku object = {
  name: 'Standard'
  tier: 'Standard'
}
param location string
param maxSizeBytes int
param zoneRedundant bool = false
param licenseType string = 'LicenseIncluded'
param numberOfReplicas int = 0
param minCapacity int = 20000
param autoPauseDelay int = -1

@description('resource id of a user assigned identity to be used by default.')
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

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  location: location
  name: '${cloudProviderServer}${cloudRegionServer}${cloudServiceServer}1${randomString}${randomNumber}'
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    administrators: administrators
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  location: location
  name: '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}-DB01'
  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
    zoneRedundant: zoneRedundant
    licenseType: licenseType
    highAvailabilityReplicaCount: numberOfReplicas
    minCapacity: minCapacity
    autoPauseDelay: autoPauseDelay
    requestedBackupStorageRedundancy: 'Local'
  }
  sku: sku
}

resource sqlConnectionPolicies 'Microsoft.Sql/servers/connectionPolicies@2021-11-01' = {
  parent: sqlServer
  name: 'Default'
  properties: {
    connectionType: connectionType
  }
}

output databaseId string = sqlServer.id
