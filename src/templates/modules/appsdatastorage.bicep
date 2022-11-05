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

@description('URI of the Key Vault where encryption key of the Storage Account is stored.')
param keyVaultUri string

@description('Enable diagnostics to store Storage Account access logs.')
param enableDiagnostics bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Storage Account. Must be defined if enableDiagnostics is true.')
param diagnosticsWorkspaceName string

@description('Retention days Storage Account access logs. Must be defined if enableDiagnostics is true.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

@description('List of Subnet names allowed to access the Storage Account in the firewall.')
param allowedSubnetNames array = []

@description('List of IPs or CIDRs allowed to access the Storage Account in the firewall.')
param allowedIPsOrCIDRs array = []

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var storageAccountName = 'azmxst1${storageAccountNameSuffix}'

var encryptionKeyName = 'merchantfileskey'

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
    type: 'SystemAssigned'
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
    publicNetworkAccess: 'Disabled'
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

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM04'
  scope: appsDataStorageAccount
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

resource apsDataStorageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AL03'
  scope: appsDataStorageAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage Account for application data should not be deleted.'
  }
}

@description('ID of the Storage Account.')
output storageAccountId string = appsDataStorageAccount.id

@description('ID of the Managed Identity of Storage Account.')
output storageAccountManagedIdentityId string = managedIdentity.id
