/**
 * Module: aks-agic-agwgroup-rbac
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

@description('Role Definition IDs for AKS to App Gateway communication (AGW scope).')
var aksAppGatewayRoleDefinitions2 = [
  {
    roleName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    roleDescription: 'Contributor | Grants full access to manage all resources'
    roleAssignmentDescription: 'Allow AGIC AKS to view and update Application Gateway configuration.'
  }
]

resource aksAppGatewayRoleAssignments2 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions2: if (aksAGICPrincipalId != '') {
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
