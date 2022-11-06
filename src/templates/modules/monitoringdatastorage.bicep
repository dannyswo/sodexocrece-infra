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

@description('Enable Resource Lock on Monitoring Data Storage Account.')
param enableLock bool

@description('List of Subnet names allowed to access the Storage Account in the firewall.')
param allowedSubnetNames array = []

@description('List of IPs or CIDRs allowed to access the Storage Account in the firewall.')
param allowedIPsOrCIDRs array = []

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

// Resource definitions

var virtualNetworkRules = [for allowedSubnetName in allowedSubnetNames: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', allowedSubnetName)
  action: 'Allow'
}]

var ipRules = [for allowedIPOrCIDR in allowedIPsOrCIDRs: {
  value: allowedIPOrCIDR
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
      ipRules: ipRules
    }
    minimumTlsVersion: 'TLS1_2'
  }
  tags: standardTags
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
  name: 'sqlserverassessments'
  parent: blobServices
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

resource monitoringDataStorageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL01'
  scope: monitoringDataStorageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage Account for monitoring data should not be deleted.'
  }
}

@description('ID of the Storage Account.')
output storageAccountId string = monitoringDataStorageAccount.id

@description('Name of the Storage Account.')
output storageAccountName string = monitoringDataStorageAccount.name

@description('URI of the blob service of the Storage Account.')
output storageAccountBlobServiceUri string = monitoringDataStorageAccount.properties.primaryEndpoints.blob
