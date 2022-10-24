param location string = 'eastus2'
param accessTier string = 'Hot'
param minimumTlsVersion string = '1.2'
param supportsHttpsTrafficOnly bool = true
param publicNetworkAccess string = 'Disabled'
param allowBlobPublicAccess bool = false
param allowSharedKeyAccess bool = false
param allowCrossTenantReplication bool = false
param defaultOAuth bool = false
param accountType string = 'Standard_LRS'
param networkAclsBypass string
param networkAclsDefaultAction string
param dnsEndpointType string
param keySource string
param encryptionEnabled bool
param keyTypeForTableAndQueueEncryption string
param infrastructureEncryptionEnabled bool
param blobSoftDeleteRetentionDays int
param containerSoftDeleteRetentionDays int
param kind string = 'StorageV2'
param randomString string
param randomNumber int

var cloudProvider = 'az'
var cloudRegion = 'mx'
var cloudService = 'st'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: '${cloudProvider}${cloudRegion}${cloudService}1${randomString}${randomNumber}'
  location: location
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    publicNetworkAccess: publicNetworkAccess
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    defaultToOAuthAuthentication: defaultOAuth
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: []
    }
    dnsEndpointType: dnsEndpointType
    encryption: {
      keySource: keySource
      services: {
        blob: {
          enabled: encryptionEnabled
        }
        file: {
          enabled: encryptionEnabled
        }
        table: {
          enabled: encryptionEnabled
          keyType: keyTypeForTableAndQueueEncryption
        }
        queue: {
          enabled: encryptionEnabled
          keyType: keyTypeForTableAndQueueEncryption
        }
      }
      requireInfrastructureEncryption: infrastructureEncryptionEnabled
    }
  }
  sku: {
    name: accountType
  }
  kind: kind
  dependsOn: []
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    restorePolicy: {
      enabled: true
    }
    deleteRetentionPolicy: {
      enabled: true
      days: blobSoftDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: containerSoftDeleteRetentionDays
    }
    isVersioningEnabled: false
  }
}

resource symbolicname 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'MerchantFiles'
  parent: blobServices
  properties: {
    denyEncryptionScopeOverride: false
    enableNfsV3AllSquash: false
    enableNfsV3RootSquash: false
    immutableStorageWithVersioning: {
      enabled: false
    }
    metadata: {}
    publicAccess: 'None'
  }
}
