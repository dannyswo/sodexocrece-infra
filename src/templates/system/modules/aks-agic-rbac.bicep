/**
 * Module: aks-rbac
 * Depends on: aks
 * Used by: system/main-system
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the AGIC add-on in the AKS Managed Cluster.')
param aksAGICPrincipalId string

@description('Name of the Application Gateway managed by AGIC add-on.')
param appGatewayName string

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AGIC add-on to Application Gateway ====================================

@description('Role Definition IDs for AKS to Application Gateway communication (RG scope).')
var aksAppGatewayRoleDefinitions1 = [
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
]

resource aksAppGatewayRoleAssignments1 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions1: if (aksAGICPrincipalId != '') {
  name: guid(resourceGroup().id, aksAGICPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksAGICPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

@description('Role Definition IDs for AKS to App Gateway communication (AGW scope).')
var aksAppGatewayRoleDefinitions2 = [
  {
    roleName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    roleDescription: 'Contributor | Grants full access to manage all resources'
    roleAssignmentDescription: 'Allow AGIC AKS to view and update Application Gateway configuration.'
  }
]

resource aksAppGatewayRoleAssignments2 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions2: if (aksAGICPrincipalId != '') {
  name: guid(appGateway.id, aksAGICPrincipalId, roleDefinition.roleName)
  scope: appGateway
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksAGICPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

resource appGateway 'Microsoft.Network/applicationGateways@2022-05-01' existing = {
  name: appGatewayName
}

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
