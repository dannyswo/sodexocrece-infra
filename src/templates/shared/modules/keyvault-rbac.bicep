/**
 * Module: keyvault-rbac
 * Depends on: managed-identities, keyvault
 * Used by: shared/main-shared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the Key Vault.')
param keyVaultName string

@description('Principal ID of the Managed Identity of Application Gateway.')
param appGatewayManagedIdentityPrincipalId string

@description('Principal ID of the Managed Identity of applications Storage Account.')
param appsStorageAccountManagedIdentityPrincipalId string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: Application Gateway Managed Identity ====================================

var appGatewayManagedIdentityRoleDefinitions = [
  {
    roleName: 'a4417e6f-fecd-4de8-b567-7b0420556985'
    roleDescription: 'Key Vault Certificates Officer | Perform any action on the certificates of a key vault.'
    roleAssignmentDescription: 'Application Gateway can access Certificates in the Key Vault.'
  }
  {
    roleName: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    roleDescription: 'Key Vault Secrets Officer | Perform any action on the secrets of a key vault'
    roleAssignmentDescription: 'Application Gateway can access Secrets in the Key Vault.'
  }
]

resource appGatewayManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appGatewayManagedIdentityRoleDefinitions: {
  name: guid(keyVault.id, appGatewayManagedIdentityPrincipalId, roleDefinition.roleName)
  scope: keyVault
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appGatewayManagedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Role Assignments: Applications data Storage Account Managed Identity ====================================

var appsStorageAccountManagedIdentityRoleDefinitions = [
  {
    roleName: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
    roleDescription: 'Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.'
    roleAssignmentDescription: 'Storage Account for applications data can access Encryption Key in the Key Vault.'
  }
]

resource appsStorageAccountManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appsStorageAccountManagedIdentityRoleDefinitions: {
  name: guid(keyVault.id, appsStorageAccountManagedIdentityPrincipalId, roleDefinition.roleName)
  scope: keyVault
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appsStorageAccountManagedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Scope ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
