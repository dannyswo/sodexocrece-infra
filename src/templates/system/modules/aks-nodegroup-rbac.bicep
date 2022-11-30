/**
 * Module: aks-nodegroup-rbac
 * Depends on: aks
 * Used by: system/main-system
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the kubelet process in the AKS Managed Cluster.')
param aksKubeletPrincipalId string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AKS kubelet AAD Pod-Managed Identities ====================================

var aksPodIdentityRoleDefinitions = [
  {
    roleName: '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
    roleDescription: 'Virtual Machine Contributor | Lets you manage virtual machines, but not access to them'
    roleAssignmentDescription: 'Allow AKS kubelet process to view and assign Managed Identities.'
  }
]

resource aksPodIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksPodIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, aksKubeletPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksKubeletPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
