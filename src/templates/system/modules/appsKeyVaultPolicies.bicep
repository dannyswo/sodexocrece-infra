/**
 * Module: appskeyvault-policies
 * Depends on: appskeyvault
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the Key Vault.')
param keyVaultName string

@description('ID of the AAD Tenant of the Principal IDs.')
param tenantId string = subscription().tenantId

@description('List of applications AAD Principal IDs allowed to read Secrets.')
param applicationsPrincipalIds array

@description('List of administrators AAD Principal IDs allowed to manage Key Vault objects.')
param teamPrincipalIds array = []

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

var teamAccessPolicies = [for teamMemberPrincipalId in teamPrincipalIds: {
  objectId: teamMemberPrincipalId
  tenantId: tenantId
  permissions: {
    certificates: allCertificatesPermissions
    keys: allKeysPermissions
    secrets: allSecretsPermissions
  }
}]

var accessPolicies = concat(applicationsAccessPolicies, teamAccessPolicies)

resource appsKeyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: appsKeyVault
  properties: {
    accessPolicies: accessPolicies
  }
}

// ==================================== Key Vault ====================================

resource appsKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

// ==================================== Outputs ====================================

output appsKeyVaultAccessPoliciesAdded string = 'added'
