@description('Azure region to deploy the Private Endpoint.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Suffix used in the Sotrage Account name.')
@minLength(6)
@maxLength(6)
param dataStorageNameSuffix string

@description('SKU name of the Storage Account.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
param dataStorageSkuName string

@description('URI of the Key Vault where encryption key of the Storage Account is stored.')
param keyVaultUri string

@description('Name of the target Log Analytics Workspace where Storage Account access logs will be stored.')
param targetWorkspaceName string

@description('Retention days of access logs of the Storage Account.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var storageAccountName = 'azmxst1${dataStorageNameSuffix}'

var encryptionKeyName = 'MerchantFilesKey'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'StorageV2'
  sku: {
    name: dataStorageSkuName
  }
  properties: {
    accessTier: 'Hot'
    immutableStorageWithVersioning: {
      enabled: false
    }
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
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    minimumTlsVersion: '1.2'
  }
  tags: standardTags
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
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
  name: 'MerchantFiles'
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

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD03'
  location: location
  tags: standardTags
}

@description('ID of the Role Definition: Key Vault Crypto User | Perform cryptographic operations using keys.')
var roleDefinitionId = '12338af0-0e69-4776-bea7-57ae8d297424'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD04'
  scope: resourceGroup()
  properties: {
    description: 'Access encryption key in the Key Vault from Storage Account \'${storageAccountName}\''
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

var targetWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', targetWorkspaceName)

resource storageAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM10'
  scope: storageAccount
  properties: {
    workspaceId: targetWorkspaceId
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

resource storageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AL03'
  scope: storageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage Account for application data should not be deleted.'
  }
}

@description('ID of the Storage Account.')
output storageAccountId string = storageAccount.id

@description('ID of the Managed Identity of Storage Account.')
output storageAccountManagedIdentityId string = managedIdentity.id
