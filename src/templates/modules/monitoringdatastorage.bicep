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

@description('Suffix used in the Storage Account name.')
@minLength(6)
@maxLength(6)
param storageAccountNameSuffix string

@description('SKU name of the Storage Account.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
param storageAccountSkuName string

@description('List of Subnet names allowed to access the Storage Account in the firewall.')
param allowedSubnetNames array = []

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var virtualNetworkRules = [for allowedSubnetName in allowedSubnetNames: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', allowedSubnetName)
  action: 'Allow'
}]

resource monitoringDataStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'azmxst1${storageAccountNameSuffix}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: true
    isNfsV3Enabled: false
    isSftpEnabled: false
    largeFileSharesState: 'Disabled'
    immutableStorageWithVersioning: {
      enabled: false
    }
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: false
    isLocalUserEnabled: false
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: virtualNetworkRules
      ipRules: []
    }
    minimumTlsVersion: '1.2'
  }
  tags: standardTags
}

resource monitoringDataStorageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AL06'
  scope: monitoringDataStorageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage Account for monitoring data should not be deleted.'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  parent: monitoringDataStorageAccount
  properties: {
    isVersioningEnabled: false
    restorePolicy: {
      enabled: false
    }
    deleteRetentionPolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource sqlServerAssessmentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'SQLServerAssessments'
  parent: blobServices
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    enableNfsV3AllSquash: false
    enableNfsV3RootSquash: false
    publicAccess: 'None'
    metadata: {}
  }
}

@description('ID of the Storage Account.')
output storageAccountId string = monitoringDataStorageAccount.id

@description('Name of the Storage Account.')
output storageAccountName string = monitoringDataStorageAccount.name
