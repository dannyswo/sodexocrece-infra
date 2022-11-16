/**
 * Module: aksNodeGroupRbac
 * Depends on: aks
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('ID of the AKS Managed Cluster.')
param aksClusterId string

@description('Principal ID of the Managed Identity of App 1.')
param app1ManageIdentityId string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AKS kubelet AAD Pod-Managed Identities ====================================

var aksPodIdentityRoleDefinitions = [
  {
    roleName: '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
    roleDescription: 'Virtual Machine Contributor | Lets you manage virtual machines, but not access to them'
    roleAssignmentDescription: 'View and change Managed Identities from AGIC AKS Add-on.'
  }
]

resource aksPodIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksPodIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, aksClusterId, app1ManageIdentityId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: app1ManageIdentityId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
