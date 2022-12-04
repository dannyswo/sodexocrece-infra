/**
 * Module: aks-kubelet-rbac
 * Depends on: aks
 * Used by: system/main-system
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the kubelet process in the AKS Managed Cluster.')
param aksKubeletPrincipalId string

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AKS kubelet to ACR ====================================

@description('Role Definition IDs for AKS to ACR communication.')
var aksAcrRoleDefinitions = [
  {
    roleName: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    roleDescription: 'AcrPull | acr pull'
    roleAssignmentDescription: 'Allow AKS to pull container images from ACR.'
  }
]

resource aksAcrRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAcrRoleDefinitions: {
  name: guid(resourceGroup().id, aksKubeletPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksKubeletPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Role Assignments: AKS kubelet AAD Pod-Managed Identities ====================================

@description('Role Definition IDs for AKS Pod-Managed Identity add-on (project RG scope).')
var aksPodIdentityRoleDefinitions = [
  {
    roleName: 'f1a07417-d97a-45cb-824c-7a7467783830'
    roleDescription: 'Managed Identity Operator | Read and Assign User Assigned Identity'
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
