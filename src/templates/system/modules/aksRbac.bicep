/**
 * Module: aksRbac
 * Depends on: aks
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('ID of the AAD Tenant used to register new custom Role Definitions.')
param tenantId string = subscription().tenantId

@description('ID of the AKS Managed Cluster.')
param aksClusterId string

@description('Principal ID of the kubelet process in the AKS Managed Cluster.')
param aksKubeletPrincipalId string

@description('Principal ID of the AGIC add-on in the AKS Managed Cluster.')
param aksAGICPrincipalId string

@description('Name of the Application Gateway managed by AGIC add-on.')
param appGatewayName string

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AKS kubelet to ACR ====================================

@description('Role Definition IDs for AKS to ACR communication.')
var aksAcrRoleDefinitions = [
  {
    roleName: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    roleDescription: 'AcrPull | acr pull'
    roleAssignmentDescription: 'Pull container images from ACR in AKS.'
  }
]

resource aksAcrRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAcrRoleDefinitions: {
  name: guid(resourceGroup().id, aksClusterId, aksKubeletPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksKubeletPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Role Assignments: AGIC add-on to Application Gateway ====================================

@description('Role Definition IDs for AKS to Application Gateway communication (RG scope).')
var aksAppGatewayRoleDefinitions1 = [
  {
    roleName: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    roleDescription: 'Reader | View all resources, but does not allow you to make any changes'
    roleAssignmentDescription: 'View and list resources from Resource Group where AKS Managed Cluster is deployed.'
  }
  {
    roleName: 'f1a07417-d97a-45cb-824c-7a7467783830'
    roleDescription: 'Managed Identity Operator | Read and Assign User Assigned Identity'
    roleAssignmentDescription: 'View and change Managed Identities from AGIC AKS Add-on.'
  }
]

resource aksAppGatewayRoleAssignments1 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions1: if (aksAGICPrincipalId != '') {
  name: guid(resourceGroup().id, aksClusterId, aksAGICPrincipalId, roleDefinition.roleName)
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
    roleAssignmentDescription: 'Manage Application Gateway from AGIC AKS Add-on.'
  }
  // {
  //   roleName: appGatewayAdminRoleDefinition.name
  //   roleDescription: 'Application Gateway Administrator | View and edit properties of an Application Gateway.'
  //   roleAssignmentDescription: 'Manage Application Gateway from AGIC AKS Add-on.'
  // }
]

resource aksAppGatewayRoleAssignments2 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions2: if (aksAGICPrincipalId != '') {
  name: guid(resourceGroup().id, aksClusterId, aksAGICPrincipalId, roleDefinition.roleName)
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

// ==================================== Role Assignments: AKS kubelet AAD Pod-Managed Identities ====================================

var aksPodIdentityRoleDefinitions = [
  {
    roleName: 'f1a07417-d97a-45cb-824c-7a7467783830'
    roleDescription: 'Managed Identity Operator | Read and Assign User Assigned Identity'
    roleAssignmentDescription: 'View and assign Managed Identities from AKS kubelet process.'
  }
]

resource aksPodIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksPodIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, aksClusterId, aksKubeletPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksKubeletPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Custom Role Definitions ====================================

var appGatewayAdminRoleName = 'Application Gateway Administrator'

resource appGatewayAdminRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(tenantId, resourceGroup().id, aksClusterId, appGatewayAdminRoleName)
  properties: {
    roleName: appGatewayAdminRoleName
    description: 'View and edit properties of an Application Gateway.'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Network/applicationGateways/read'
          'Microsoft.Network/applicationGateways/write'
          'Microsoft.Network/applicationGateways/getMigrationStatus/action'
          'Microsoft.Network/applicationGateways/effectiveNetworkSecurityGroups/action'
          'Microsoft.Network/applicationGateways/effectiveRouteTable/action'
          'Microsoft.Network/applicationGateways/backendAddressPools/join/action'
          'Microsoft.Network/applicationGateways/providers/Microsoft.Insights/metricDefinitions/read'
          'Microsoft.Network/applicationGateways/providers/Microsoft.Insights/logDefinitions/read'
          'Microsoft.Network/applicationGateways/privateLinkResources/read'
          'Microsoft.Network/applicationGateways/privateLinkConfigurations/read'
          'Microsoft.Network/applicationGateways/privateEndpointConnections/write'
          'Microsoft.Network/applicationGateways/privateEndpointConnections/read'
          'Microsoft.Network/applicationGateways/restart/action'
          'Microsoft.Network/applicationGateways/stop/action'
          'Microsoft.Network/applicationGateways/start/action'
          'Microsoft.Network/applicationGateways/resolvePrivateLinkServiceId/action'
          'Microsoft.Network/applicationGateways/getBackendHealthOnDemand/action'
          'Microsoft.Network/applicationGateways/backendhealth/action'
        ]
        notActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
