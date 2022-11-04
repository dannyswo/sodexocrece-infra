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
