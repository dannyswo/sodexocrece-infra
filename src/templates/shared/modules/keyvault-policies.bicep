/**
 * Module: keyvault-policies
 * Depends on: managed-identities, keyvault
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the Key Vault.')
param keyVaultName string

@description('ID of the AAD Tenant of the Principal IDs.')
param tenantId string = subscription().tenantId

@description('ID of the Managed Identity used by Application Gateway.')
param appGatewayManagedIdentityPrincipalId string

@description('ID of the Managed Identity used by applications Storage Account.')
param appsStorageAccountManagedIdentityPrincipalId string

@description('ID of the Managed Identity used by Container Registry.')
param acrManagedIdentityPrincipalId string

@description('List of administrators Principal IDs allowed to fully manage Key Vault objects.')
param adminsPrincipalIds array

@description('List of readers AAD Principal IDs allowed to only read Key Vault objects.')
param readersPrincipalIds array

// ==================================== Resources ====================================

// ==================================== Key Vault Access Policies ====================================

var appGatewayAccessPolicy = {
  objectId: appGatewayManagedIdentityPrincipalId
  tenantId: tenantId
  permissions: {
    keys: allKeysPermissions
    secrets: allSecretsPermissions
    certificates: allCertificatesPermissions
  }
}

var appsStorageAccountAccessPolicy = {
  objectId: appsStorageAccountManagedIdentityPrincipalId
  tenantId: tenantId
  permissions: {
    keys: allKeysPermissions
    secrets: []
    certificates: []
  }
}

var acrAccessPolicy = {
  objectId: acrManagedIdentityPrincipalId
  tenantId: tenantId
  permissions: {
    keys: allKeysPermissions
    secrets: []
    certificates: []
  }
}

var azureServicesAccessPolicies = [
  appGatewayAccessPolicy
  appsStorageAccountAccessPolicy
  acrAccessPolicy
]

var adminsAccessPolicies = [for adminPrincipalId in adminsPrincipalIds: {
  objectId: adminPrincipalId
  tenantId: tenantId
  permissions: {
    keys: allKeysPermissions
    secrets: allSecretsPermissions
    certificates: allCertificatesPermissions
  }
}]

var readersAccessPolicies = [for readerPrincipalId in readersPrincipalIds: {
  objectId: readerPrincipalId
  tenantId: tenantId
  permissions: {
    keys: [
      'get'
      'list'
      'decrypt'
      'encrypt'
      'getrotationpolicy'
      'sign'
      'verify'
    ]
    secrets: [
      'get'
      'list'
    ]
    certificates: [
      'get'
      'list'
    ]
  }
}]

var accessPolicies = concat(azureServicesAccessPolicies, adminsAccessPolicies, readersAccessPolicies)

resource appsKeyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: accessPolicies
  }
}

// ==================================== Key Vault List of Permissions ====================================

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

// ==================================== Key Vault ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

// ==================================== Outputs ====================================

output keyVaultAccessPoliciesAdded string = 'added'
