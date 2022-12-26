/**
 * Module: aks-agic-rbac
 * Depends on: aks
 * Used by: system/main-system
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the AGIC add-on in the AKS Managed Cluster.')
param aksAGICPrincipalId string

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AGIC add-on to Application Gateway ====================================

var aksAppGatewayRoleDefinitions = [
  {
    roleName: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    roleDescription: 'Reader | View all resources, but does not allow you to make any changes'
    roleAssignmentDescription: 'Allow AKS AGIC to view and list resources from Resource Group where AKS Managed Cluster is deployed.'
  }
  {
    roleName: 'f1a07417-d97a-45cb-824c-7a7467783830'
    roleDescription: 'Managed Identity Operator | Read and Assign User Assigned Identity'
    roleAssignmentDescription: 'Allow AKS AGIC to view and assign Managed Identities.'
  }
  {
    roleName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    roleDescription: 'Contributor | Grants full access to manage all resources'
    roleAssignmentDescription: 'Allow AGIC AKS to view and update Application Gateway configuration.'
  }
]

resource aksAppGatewayRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions: if (aksAGICPrincipalId != '') {
  name: guid(resourceGroup().id, aksAGICPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksAGICPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
