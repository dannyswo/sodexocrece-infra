/**
 * Module: infrakeyvault-rbac
 * Depends on: infrakeyvault, inframanagedids, infrausers
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the infrastructure Key Vault.')
param infraKeyVaultName string

@description('Principal ID of the system administrator.')
param administratorPrincipalId string

@description('ID of the Managed Identity of Application Gateway.')
param appGatewayManagedIdentityName string

@description('ID of the Managed Identity of applications data Storage Account.')
param appsDataStorageManagedIdentityName string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: Administrator ====================================

var administratorRoleDefinitions = [
  {
    roleName: 'f25e0fa2-a7c8-4377-a976-54943a77a395'
    roleDescription: 'Key Vault Contributor | Lets you manage key vaults'
    roleAssignmentDescription: 'System administrator can execute management operations on Key Vault.'
    scope: 'KeyVault'
  }
  {
    roleName: '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8'
    roleDescription: 'Azure Kubernetes Service Cluster Admin Role | List cluster admin credential action'
    roleAssignmentDescription: 'System administrator can obtain admin credentials on AKS Managed Cluster.'
    scope: 'KeyVault'
  }
]

resource administratorRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in administratorRoleDefinitions: {
  name: guid(infraKeyVault.id, administratorPrincipalId, roleDefinition.roleName)
  scope: infraKeyVault
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: administratorPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'User'
  }
}]

// ==================================== Role Assignments: Application Gateway Managed Identity ====================================

var appGatewayManagedIdentityRoleDefinitions = [
  {
    roleName: 'a4417e6f-fecd-4de8-b567-7b0420556985'
    roleDescription: 'Key Vault Certificates Officer | Perform any action on the certificates of a key vault.'
    roleAssignmentDescription: 'Application Gateway can access Certificates in the infrastructure Key Vault.'
  }
  {
    roleName: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    roleDescription: 'Key Vault Secrets Officer | Perform any action on the secrets of a key vault'
    roleAssignmentDescription: 'Application Gateway can access Secrets in the infrastructure Key Vault.'
  }
]

resource appGatewayManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appGatewayManagedIdentityRoleDefinitions: {
  name: guid(infraKeyVault.id, appGatewayManagedIdentity.id, roleDefinition.roleName)
  scope: infraKeyVault
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appGatewayManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Role Assignments: Applications data Storage Account Managed Identity ====================================

var appsDataStorageManagedIdentityRoleDefinitions = [
  {
    roleName: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
    roleDescription: 'Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.'
    roleAssignmentDescription: 'Storage Account for applications data can access Encryption Key in the infrastructure Key Vault.'
  }
]

resource appsDataStorageManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appsDataStorageManagedIdentityRoleDefinitions: {
  name: guid(infraKeyVault.id, appsDataStorageManagedIdentity.id, roleDefinition.roleName)
  scope: infraKeyVault
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appsDataStorageManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Scope ====================================

resource infraKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: infraKeyVaultName
}

// ==================================== Security Principals ====================================

resource appGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: appGatewayManagedIdentityName
}

resource appsDataStorageManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: appsDataStorageManagedIdentityName
}

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
