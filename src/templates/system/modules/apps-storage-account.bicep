/**
 * Module: apps-storage-account
 * Depends on: managed-identities, keyvault, monitoring-loganalytics-workspace
 * Used by: system/main-system
 * Common resources: RL06, MM06, AD02
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

@description('Name of the Managed Identity used by applications Storage Account.')
param managedIdentityName string

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

@description('Name of the Key Vault where Encryption Key of the Storage Account is stored.')
param keyVaultName string

@description('Name of the CMK used by Storage Account to encrypt blobs.')
param encryptionKeyName string

// ==================================== Diagnostics options ====================================

@description('Enable diagnostics to store Storage Account access logs.')
param enableDiagnostics bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Storage Account. Must be defined if enableDiagnostics is true.')
param diagnosticsWorkspaceName string

@description('Retention days of the Storage Account access logs. Must be defined if enableDiagnostics is true.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on applications Storage Account.')
param enableLock bool

// ==================================== PaaS Firewall settings ====================================

@description('Enable public access in the PaaS firewall.')
param enablePublicAccess bool

@description('Allow bypass of PaaS firewall rules to Azure Services.')
param bypassAzureServices bool

@description('List of Subnet IDs allowed to access the Storage Account in the PaaS firewall.')
param allowedSubnetIds array

@description('List of IPs or CIDRs allowed to access the Storage Account in the PaaS firewall.')
param allowedIPsOrCIDRs array

// ==================================== Resources ====================================

// ==================================== Stoarge Account ====================================

var virtualNetworkRules = [for allowedSubnetId in allowedSubnetIds: {
  id: allowedSubnetId
  action: 'Allow'
}]

var ipRules = [for allowedIPOrCIDR in allowedIPsOrCIDRs: {
  value: allowedIPOrCIDR
}]

resource appsStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'azmxst1${storageAccountNameSuffix}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
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
    encryption: {
      identity: {
        userAssignedIdentity: managedIdentity.id
      }
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: encryptionKeyName
        keyvaulturi: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/'
      }
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
      }
      requireInfrastructureEncryption: false
    }
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: false
    isLocalUserEnabled: false
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'PrivateLink'
    publicNetworkAccess: (enablePublicAccess) ? 'Enabled' : 'Disabled'
    networkAcls: {
      bypass: (bypassAzureServices) ? 'AzureServices' : 'None'
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
  parent: appsStorageAccount
  properties: {
    automaticSnapshotPolicyEnabled: false
    restorePolicy: {
      enabled: false
    }
    deleteRetentionPolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: false
    }
    isVersioningEnabled: false
    changeFeed: {
      enabled: false
    }
  }
}

// ==================================== Managed Identity ====================================

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

// ==================================== Diagnostics ====================================

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM06'
  scope: blobServices
  properties: {
    workspaceId: resourceId('Microsoft.OperationalInsights/workspaces', diagnosticsWorkspaceName)
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
    ]
  }
}

// ==================================== Resource Lock ====================================

resource appsStorageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL06'
  scope: appsStorageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage Account for application data should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the Storage Account.')
output storageAccountId string = appsStorageAccount.id

@description('Name of the Storage Account.')
output storageAccountName string = appsStorageAccount.name

@description('URI of the Blob Service of the Storage Account.')
output storageAccountBlobServiceUri string = appsStorageAccount.properties.primaryEndpoints.blob
