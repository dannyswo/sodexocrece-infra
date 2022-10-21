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
param isContainerRestoreEnabled bool
param isBlobSoftDeleteEnabled bool
param blobSoftDeleteRetentionDays int
param isContainerSoftDeleteEnabled bool
param containerSoftDeleteRetentionDays int
param changeFeed bool
param isVersioningEnabled bool
param isShareSoftDeleteEnabled bool
param shareSoftDeleteRetentionDays int
param kind string = 'StorageV2'

param randomString string = 'ifv'
param randomNumber int = 691


var cloudProvider = 'AZ'
var cloudRegion = 'US'
var cloudService = 'ST'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
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

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    restorePolicy: {
      enabled: isContainerRestoreEnabled
    }
    deleteRetentionPolicy: {
      enabled: isBlobSoftDeleteEnabled
      days: blobSoftDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: isContainerSoftDeleteEnabled
      days: containerSoftDeleteRetentionDays
    }
    changeFeed: {
      enabled: changeFeed
    }
    isVersioningEnabled: isVersioningEnabled
  }
}

resource Microsoft_Storage_storageAccounts_fileservices_storageAccountName_default 'Microsoft.Storage/storageAccounts/fileservices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: isShareSoftDeleteEnabled
      days: shareSoftDeleteRetentionDays
    }
  }
  dependsOn: [

    storageAccountName_default
  ]
}
