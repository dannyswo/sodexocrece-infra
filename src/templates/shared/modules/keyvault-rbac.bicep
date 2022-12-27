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

@description('Principal ID of the Managed Identity of Container Registry.')
param acrManagedIdentityPrincipalId string

@description('Principal ID of the Managed Identity of container application 1.')
param containerApp1ManagedIdentityPrincipalId string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: Application Gateway Managed Identity ====================================

@description('Role Definition IDs for Application Gateway under Key Vault scope.')
var appGatewayManagedIdentityRoleDefinitions = [
  {
    roleName: 'a4417e6f-fecd-4de8-b567-7b0420556985'
    roleDescription: 'Key Vault Certificates Officer | Perform any action on the certificates of a key vault.'
    roleAssignmentDescription: 'Allow Application Gateway to access Certificates in the Key Vault.'
  }
  {
    roleName: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    roleDescription: 'Key Vault Secrets Officer | Perform any action on the secrets of a key vault'
    roleAssignmentDescription: 'Allow Application Gateway to access Secrets in the Key Vault.'
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

@description('Role Definition IDs for applications Storage Account under Key Vault scope.')
var appsStorageAccountManagedIdentityRoleDefinitions = [
  {
    roleName: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
    roleDescription: 'Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.'
    roleAssignmentDescription: 'Allow applications data Storage Account to access Encryption Key in the Key Vault.'
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

// ==================================== Role Assignments: Container Registry Managed Identity ====================================

@description('Role Definition IDs for Container Registry under Key Vault scope.')
var acrManagedIdentityRoleDefinitions = [
  {
    roleName: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
    roleDescription: 'Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.'
    roleAssignmentDescription: 'Allow Container Registry to access Encryption Key in the Key Vault.'
  }
]

resource acrManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in acrManagedIdentityRoleDefinitions: {
  name: guid(keyVault.id, acrManagedIdentityPrincipalId, roleDefinition.roleName)
  scope: keyVault
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: acrManagedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Role Assignments: Container application 1 Managed Identity ====================================

@description('Role Definition IDs for container application 1 under Key Vault scope.')
var containerApp1ManagedIdentityRoleDefinitions = [
  {
    roleName: '4633458b-17de-408a-b874-0445c86b69e6'
    roleDescription: 'Key Vault Secrets User | Read secret contents'
    roleAssignmentDescription: 'Allow container application 1 to read Secrets in Key Vault.'
  }
  {
    roleName: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
    roleDescription: 'Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.'
    roleAssignmentDescription: 'Allow container application 1 to read Encryption Key in the Key Vault.'
  }
]

resource containerApp1ManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in containerApp1ManagedIdentityRoleDefinitions: {
  name: guid(keyVault.id, containerApp1ManagedIdentityPrincipalId, roleDefinition.roleName)
  scope: keyVault
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: containerApp1ManagedIdentityPrincipalId
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
