/**
 * Module: aksKeyVaultPolicies
 * Depends on: aks, infraKeyVault
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the infrastructure Key Vault.')
param infraKeyVaultName string

@description('ID of the AAD Tenant of the Principal IDs.')
param tenantId string = subscription().tenantId

@description('ID of the Managed Identity used by AKS Key Vault Secrets Provider Add-on.')
param aksKeyVaultSecrtsProviderPrincipalId string

// ==================================== Resources ====================================

// ==================================== Key Vault Access Policies ====================================

var aksKeyVaultSecretsProviderAccessPolicy = {
  objectId: aksKeyVaultSecrtsProviderPrincipalId
  tenantId: tenantId
  permissions: {
    certificates: allCertificatesPermissions
    keys: allKeysPermissions
    secrets: allSecretsPermissions
  }
}

resource appsKeyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      aksKeyVaultSecretsProviderAccessPolicy
    ]
  }
}

// ==================================== Key Vault List of Permissions ====================================

var allCertificatesPermissions = [
  'backup'
  'create'
  'delete'
  'deleteissuers'
  'get'
  'getissuers'
  'import'
  'list'
  'listissuers'
  'managecontacts'
  'manageissuers'
  'purge'
  'recover'
  'restore'
  'setissuers'
  'update'
]

var allKeysPermissions = [
  'backup'
  'create'
  'decrypt'
  'delete'
  'encrypt'
  'get'
  'getrotationpolicy'
  'import'
  'list'
  'purge'
  'recover'
  'release'
  'restore'
  'rotate'
  'setrotationpolicy'
  'sign'
  'unwrapKey'
  'update'
  'verify'
  'wrapKey'
]

var allSecretsPermissions = [
  'backup'
  'delete'
  'get'
  'list'
  'purge'
  'recover'
  'restore'
  'set'
]

// ==================================== Key Vault ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: infraKeyVaultName
}

// ==================================== Outputs ====================================

output infraKeyVaultAccessPoliciesAdded string = 'added'
