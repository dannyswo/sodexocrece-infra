/**
 * Module: managed-identities-networkgroup-rbac
 * Depends on: managed-identities
 * Used by: shared/main-shared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the Managed Identity of AKS Managed Cluster.')
param aksManagedIdentityPrincipalId string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AKS Network Permissions ====================================

var aksManagedIdentityRoleDefinitions = [
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

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
