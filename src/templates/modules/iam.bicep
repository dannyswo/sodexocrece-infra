// ==================================== Resource definitions ====================================

@description('Principal ID of user danny.zamorano@softwareone.com')
var devopsEngineer1PrincipalId = '40c2e922-9fb6-4186-a53f-44439c85a9df'

@description('ID of the Role Definition: Key Vault Contributor | Lets you manage key vaults.')
var keyVaultAdministratorRoleDefinitionId = 'f25e0fa2-a7c8-4377-a976-54943a77a395'

resource devopsEngineer1RoleAssignments1 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, devopsEngineer1PrincipalId, keyVaultAdministratorRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    description: 'DevOps engineer 1 can execute management operations on Key Vault.'
    principalId: devopsEngineer1PrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdministratorRoleDefinitionId)
    principalType: 'User'
  }
}

var aksAdministratorRoleDefinitions = [
  {
    roleId: '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8'
    roleDescription: 'Azure Kubernetes Service Cluster Admin Role | List cluster admin credential action'
    roleAssignmentDescription: 'DevOps engineer 1 can obtain admin credentials on AKS Managed Cluster.'
  }
  {
    roleId: 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
    roleDescription: 'Azure Kubernetes Service RBAC Cluster Admin | Lets you manage all resources in the cluster'
    roleAssignmentDescription: 'DevOps engineer 1 can manage AKS Managed Cluster objects.'
  }
]

resource devopsEngineer1RoleAssignmentsAKS 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in aksAdministratorRoleDefinitions: {
  name: guid(resourceGroup().id, devopsEngineer1PrincipalId, roleDefinition.roleId)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: devopsEngineer1PrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleId)
    principalType: 'User'
  }
}]

var storageAccountAdminRoleDefinitions = [
  {
    roleId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data'
    roleAssignmentDescription: 'DevOps engineer 1 can access Storage Account Blob data.'
  }
]

resource devopsEngineer1RoleAssignmentsStorageAccount 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in storageAccountAdminRoleDefinitions: {
  name: guid(resourceGroup().id, devopsEngineer1PrincipalId, roleDefinition.roleId)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: devopsEngineer1PrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleId)
    principalType: 'User'
  }
}]

@description('Principal ID of the system owner or administrator.')
output ownerPrincipalId string = devopsEngineer1PrincipalId
