/**
 * Module: monitoring-storage-account
 * Depends on: N/A
 * Used by: shared/main-shared
 * Common resources: RL01
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

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

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

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

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on monitoring Storage Account.')
param enableLock bool

// ==================================== PaaS Firewall settings ====================================

@description('Enable public access in the PaaS firewall.')
param enablePublicAccess bool

@description('Allow bypass of PaaS firewall rules to Azure Services.')
param bypassAzureServices bool

@description('List of Subnets allowed to access the Storage Account in the PaaS firewall.')
@metadata({
  vnetName: 'Name of VNet.'
  subnetName: 'Name of the Subnet.'
})
param allowedSubnets array

@description('List of IPs or CIDRs allowed to access the Storage Account in the PaaS firewall.')
param allowedIPsOrCIDRs array

// ==================================== Resources ====================================

var virtualNetworkRules = [for allowedSubnet in allowedSubnets: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', allowedSubnet.vnetName, allowedSubnet.subnetName)
  action: 'Allow'
}]

var ipRules = [for allowedIPOrCIDR in allowedIPsOrCIDRs: {
  value: allowedIPOrCIDR
}]

resource monitoringStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
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
    publicNetworkAccess: (enablePublicAccess) ? 'Enabled' : 'Disabled'
    networkAcls: {
      bypass: (bypassAzureServices) ? 'AzureServices, Logging, Metrics' : 'None'
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
  parent: monitoringStorageAccount
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

// ==================================== Resource Lock ====================================

resource monitoringStorageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL01'
  scope: monitoringStorageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage Account for monitoring data should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the Storage Account.')
output storageAccountId string = monitoringStorageAccount.id

@description('Name of the Storage Account.')
output storageAccountName string = monitoringStorageAccount.name

@description('URI of the Blob Service of the Storage Account.')
output storageAccountBlobServiceUri string = monitoringStorageAccount.properties.primaryEndpoints.blob
