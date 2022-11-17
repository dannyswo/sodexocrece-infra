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

var ownerAdminRoleDefinition = {
  roleName: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  roleDescription: 'Owner | Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.'
  roleAssignmentDescription: 'System administrator can manage any resource in the Resource Group and assign roles.'
}

resource adminUsersRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for adminUserPrincipalId in adminUsersPrincipalIds: {
  name: guid(resourceGroup().id, adminUserPrincipalId, ownerAdminRoleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: ownerAdminRoleDefinition.roleAssignmentDescription
    principalId: adminUserPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', ownerAdminRoleDefinition.roleName)
    principalType: 'User'
  }
}]

var specificAdminRoleDefinitions = [
  {
    roleName: 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
    roleDescription: 'Azure Kubernetes Service RBAC Cluster Admin | Lets you manage all resources in the cluster'
    roleAssignmentDescription: 'System administrator can manage AKS Managed Cluster resources.'
  }
  {
    roleName: 'f25e0fa2-a7c8-4377-a976-54943a77a395'
    roleDescription: 'Key Vault Contributor | Lets you manage key vaults'
    roleAssignmentDescription: 'System administrator can execute management operations on infrastructure Key Vault.'
  }
  {
    roleName: 'a4417e6f-fecd-4de8-b567-7b0420556985'
    roleDescription: 'Key Vault Certificates Officer | Perform any action on the certificates of a key vault.'
    roleAssignmentDescription: 'System administrator can read and update Certificates in infrastructure Key Vault.'
  }
  {
    roleName: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    roleDescription: 'Key Vault Secrets Officer | Perform any action on the secrets of a key vault.'
    roleAssignmentDescription: 'System administrator can read and update Secrets in infrastructure Key Vault.'
  }
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data'
    roleAssignmentDescription: 'System administrator can read and update files in Storage Account Blob Containers.'
  }
]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
