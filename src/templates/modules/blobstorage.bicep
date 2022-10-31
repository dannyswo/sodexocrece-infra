param location string
param accessTier string = 'Hot'
param storageSKU string = 'Standard_LRS'
// param networkAclsBypass string
// param networkAclsDefaultAction string
// param keySource string
// param encryptionEnabled bool
// param keyTypeForTableAndQueueEncryption string
// param infrastructureEncryptionEnabled bool
param blobSoftDeleteRetentionDays int
param containerSoftDeleteRetentionDays int
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
    minimumTlsVersion: '1.2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    allowCrossTenantReplication: false
    defaultToOAuthAuthentication: false
    // networkAcls: {
    //   bypass: networkAclsBypass
    //   defaultAction: networkAclsDefaultAction
    //   ipRules: []
    // }
    // encryption: {
    //   keySource: keySource
    //   services: {
    //     blob: {
    //       enabled: encryptionEnabled
    //     }
    //     file: {
    //       enabled: encryptionEnabled
    //     }
    //     table: {
    //       enabled: encryptionEnabled
    //       keyType: keyTypeForTableAndQueueEncryption
    //     }
    //     queue: {
    //       enabled: encryptionEnabled
    //       keyType: keyTypeForTableAndQueueEncryption
    //     }
    //   }
    //   requireInfrastructureEncryption: infrastructureEncryptionEnabled
    // }
  }
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
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

output storageAccountId string = storageAccount.id
