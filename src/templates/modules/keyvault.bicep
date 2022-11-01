@description('Azure region to deploy the Key Vault.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param environment string

@description('Suffix used in the Key Vault name.')
@minLength(6)
@maxLength(6)
param keyVaultNameSuffix string

@description('ID of the AAD Tenant used to authenticate requests to the Key Vault.')
param tenantId string = subscription().tenantId

@description('Standard tags applied to all resources.')
param standardTags object = resourceGroup().tags

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'azmxkv1${keyVaultNameSuffix}'
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 30
    enableRbacAuthorization: false
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: []
    }
  }
  tags: standardTags
}

resource keyVaultLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-AL01'
  scope: keyVault
  properties: {
    level: 'CanNotDelete'
    notes: 'Key Vault should not be deleted.'
  }
}

@description('ID of the Key Vault instance.')
output keyVaultId string = keyVault.id

@description('URI of the Key Vault instance.')
output keyVaultUri string = keyVault.properties.vaultUri
