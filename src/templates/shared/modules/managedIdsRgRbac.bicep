/**
 * Module: managedIdsRgRbac
 * Depends on: managedIds
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the Managed Identity of AKS Managed Cluster.')
param aksManagedIdentityPrincipalId string

@description('Principal ID of the Managed Identity of Application 1.')
param app1ManagedIdentityPrincipalId string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AKS Network Permissions ====================================

var aksManagedIdentityRoleDefinitions = [
  {
    roleName: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'
    roleDescription: 'Private DNS Zone Contributor | Lets you manage private DNS zone resources.'
    roleAssignmentDescription: 'Allow AKS Managed Cluster to manage custom Private DNS Zone.'
  }
  {
    roleName: '4d97b98b-1d4f-4787-a291-c67834d212e7'
    roleDescription: 'Network Contributor | Lets you manage networks, but not access to them.'
    roleAssignmentDescription: 'Allow AKS Managed Cluster to manage custom Rouble Table.'
  }
]

resource aksManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in aksManagedIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, aksManagedIdentityPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksManagedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Role Assignments: Application 1 Azure Services Permissions ====================================

var app1ManagedIdentityRoleDefinitions = [
  {
    roleName: '4633458b-17de-408a-b874-0445c86b69e6'
    roleDescription: 'Key Vault Secrets User | Read secret contents'
    roleAssignmentDescription: 'Allow Application 1 to read secrets in infrastructure Key Vault.'
  }
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data'
    roleAssignmentDescription: 'Allow Application 1 to read and update files in Storage Account Blob Containers.'
  }
]

resource app1ManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in app1ManagedIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, app1ManagedIdentityPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: app1ManagedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
