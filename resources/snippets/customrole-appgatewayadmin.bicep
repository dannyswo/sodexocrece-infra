@description('Role Definition IDs for AKS to App Gateway communication (AGW scope).')
var aksAppGatewayRoleDefinitions2 = [
  {
    roleName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    roleDescription: 'Contributor | Grants full access to manage all resources'
    roleAssignmentDescription: 'Manage Application Gateway from AGIC AKS Add-on.'
  }
  {
    roleName: appGatewayAdminRoleDefinition.name
    roleDescription: 'Application Gateway Administrator | View and edit properties of an Application Gateway.'
    roleAssignmentDescription: 'Manage Application Gateway from AGIC AKS Add-on.'
  }
]

resource aksAppGatewayRoleAssignments2 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in aksAppGatewayRoleDefinitions2: if (aksAGICPrincipalId != '') {
  name: guid(appGateway.id, aksClusterId, aksAGICPrincipalId, roleDefinition.roleName)
  scope: appGateway
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksAGICPrincipalId
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
