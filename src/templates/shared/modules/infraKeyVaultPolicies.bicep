/**
 * Module: infraKeyVaultPolicies
 * Depends on: infraKeyVault, infraManagedids, infraUsers
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the infrastructure Key Vault.')
param infraKeyVaultName string

@description('ID of the AAD Tenant of the Principal IDs.')
param tenantId string = subscription().tenantId

@description('ID of the Managed Identity used by appGateway.')
param appGatewayPrincipalId string

@description('ID of the Managed Identity used by appsDataStorage.')
param appsDataStorageAccountPrincipalId string

@description('List of applications AAD Principal IDs allowed to read Secrets.')
param applicationsPrincipalIds array = []

@description('List of administrators AAD Principal IDs allowed to manage Key Vault objects.')
param adminsPrincipalIds array = []

// ==================================== Resources ====================================

// ==================================== Key Vault Access Policies ====================================

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

var appGatewayAccessPolicy = {
  objectId: appGatewayPrincipalId
  tenantId: tenantId
  permissions: {
    certificates: allCertificatesPermissions
    keys: allKeysPermissions
    secrets: allSecretsPermissions
  }
}

var appsDataStorageAccountAccessPolicy = {
  objectId: appsDataStorageAccountPrincipalId
  tenantId: tenantId
  permissions: {
    keys: allKeysPermissions
  }
}

var azureServicesAccessPolicies = [
  appGatewayAccessPolicy
  appsDataStorageAccountAccessPolicy
]

var applicationsAccessPolicies = [for applicationPrincipalId in applicationsPrincipalIds: {
  objectId: applicationPrincipalId
  tenantId: tenantId
  permissions: {
    secrets: [
      'get'
      'list'
    ]
  }
}]

var adminsAccessPolicies = [for adminPrincipalId in adminsPrincipalIds: {
  objectId: adminPrincipalId
  tenantId: tenantId
  permissions: {
    certificates: allCertificatesPermissions
    keys: allKeysPermissions
    secrets: allSecretsPermissions
  }
}]

var accessPolicies = concat(azureServicesAccessPolicies, applicationsAccessPolicies, adminsAccessPolicies)

resource appsKeyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: accessPolicies
  }
}

// ==================================== Key Vault ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: infraKeyVaultName
}

// ==================================== Outputs ====================================

output appsKeyVaultAccessPoliciesAdded string = 'added'
