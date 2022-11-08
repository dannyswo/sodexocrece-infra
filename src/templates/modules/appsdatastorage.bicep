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

@description('Name of the Managed Identity used by Application Data Storage Account.')
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

@description('Name of the CMK used by Storage Account to encrypt blobs.')
param encryptionKeyName string

@description('URI of the Key Vault where encryption key of the Storage Account is stored.')
param keyVaultUri string

@description('Enable diagnostics to store Storage Account access logs.')
param enableDiagnostics bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Storage Account. Must be defined if enableDiagnostics is true.')
param diagnosticsWorkspaceName string

@description('Retention days of the Storage Account access logs. Must be defined if enableDiagnostics is true.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

@description('Enable Resource Lock on Application Gateway.')
param enableLock bool

@description('Enable public access in the PaaS firewall.')
param enablePublicAccess bool

@description('List of Subnet names allowed to access the Storage Account in the PaaS firewall.')
param allowedSubnetNames array = []

@description('List of IPs or CIDRs allowed to access the Storage Account in the PaaS firewall.')
param allowedIPsOrCIDRs array = []

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

// Resource definitions

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

var storageAccountName = 'azmxst1${storageAccountNameSuffix}'

var virtualNetworkRules = [for allowedSubnetName in allowedSubnetNames: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', allowedSubnetName)
  action: 'Allow'
}]

var ipRules = [for allowedIPOrCIDR in allowedIPsOrCIDRs: {
  value: allowedIPOrCIDR
}]

resource appsDataStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
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
        keyvaulturi: keyVaultUri
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
      bypass: 'None'
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
  parent: appsDataStorageAccount
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

resource merchantFilesContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'merchantfiles'
  parent: blobServices
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

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

resource apsDataStorageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL06'
  scope: appsDataStorageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage Account for application data should not be deleted.'
  }
}

@description('ID of the Storage Account.')
output storageAccountId string = appsDataStorageAccount.id
