/**
 * Module: adminUsersRgRbac
 * Depends on: N/A
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of system administrator users.')
param adminUsersPrincipalIds array

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: Administrator ====================================

var adminRoleDefinitions = [
  {
    roleName: 'f25e0fa2-a7c8-4377-a976-54943a77a395'
    roleDescription: 'Key Vault Contributor | Lets you manage key vaults.'
    roleAssignmentDescription: 'System administrator can execute management operations on infrastructure Key Vault.'
  }
  {
    roleName: '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
    roleDescription: 'Key Vault Crypto Officer | Perform any action on the keys of a key vault, except manage permissions.'
    roleAssignmentDescription: 'System administrator can read and update Encryption Keys in infrastructure Key Vault.'
  }
  {
    roleName: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    roleDescription: 'Key Vault Secrets Officer | Perform any action on the secrets of a key vault.'
    roleAssignmentDescription: 'System administrator can read and update Secrets in infrastructure Key Vault.'
  }
  {
    roleName: 'a4417e6f-fecd-4de8-b567-7b0420556985'
    roleDescription: 'Key Vault Certificates Officer | Perform any action on the certificates of a key vault.'
    roleAssignmentDescription: 'System administrator can read and update Certificates in infrastructure Key Vault.'
  }
  {
    roleName: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
    roleDescription: 'Storage Account Contributor | Lets you manage storage accounts, including accessing storage account keys which provide full access to storage account data.'
    roleAssignmentDescription: 'System administrator can manage Storage Accounts.'
  }
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data.'
    roleAssignmentDescription: 'System administrator can read and update files in Storage Account Blob Containers.'
  }
  {
    roleName: 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
    roleDescription: 'Azure Kubernetes Service RBAC Cluster Admin | Lets you manage all resources in the cluster.'
    roleAssignmentDescription: 'System administrator can manage AKS Managed Cluster resources.'
  }
  {
    roleName: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    roleDescription: 'Owner | Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.'
    roleAssignmentDescription: 'System administrator can manage any resource in the Resource Group and assign roles.'
  }
]

resource adminUsersRoleAssignments1 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, adminRoleDefinitions[0].roleName)
  scope: resourceGroup()
  properties: {
    description: adminRoleDefinitions[0].roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminRoleDefinitions[0].roleName)
    principalType: 'User'
  }
}]

resource adminUsersRoleAssignments2 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, adminRoleDefinitions[1].roleName)
  scope: resourceGroup()
  properties: {
    description: adminRoleDefinitions[1].roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminRoleDefinitions[1].roleName)
    principalType: 'User'
  }
}]

resource adminUsersRoleAssignments3 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, adminRoleDefinitions[2].roleName)
  scope: resourceGroup()
  properties: {
    description: adminRoleDefinitions[2].roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminRoleDefinitions[2].roleName)
    principalType: 'User'
  }
}]

resource adminUsersRoleAssignments4 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, adminRoleDefinitions[3].roleName)
  scope: resourceGroup()
  properties: {
    description: adminRoleDefinitions[3].roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminRoleDefinitions[3].roleName)
    principalType: 'User'
  }
}]

resource adminUsersRoleAssignments5 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, adminRoleDefinitions[4].roleName)
  scope: resourceGroup()
  properties: {
    description: adminRoleDefinitions[4].roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminRoleDefinitions[4].roleName)
    principalType: 'User'
  }
}]

resource adminUsersRoleAssignments6 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, adminRoleDefinitions[5].roleName)
  scope: resourceGroup()
  properties: {
    description: adminRoleDefinitions[5].roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminRoleDefinitions[5].roleName)
    principalType: 'User'
  }
}]

resource adminUsersRoleAssignments7 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, adminRoleDefinitions[6].roleName)
  scope: resourceGroup()
  properties: {
    description: adminRoleDefinitions[6].roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminRoleDefinitions[6].roleName)
    principalType: 'User'
  }
}]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
