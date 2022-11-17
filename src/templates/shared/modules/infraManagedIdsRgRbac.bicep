/**
 * Module: infraRgRbac
 * Depends on: N/A
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('ID of the AAD Tenant used to register new custom Role Definitions.')
param tenantId string = subscription().tenantId

@description('Name of the Managed Identity of AKS Managed Cluster.')
param aksManagedIdentityName string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: AKS Networking ====================================

var aksManagedIdentityRoleDefinitions = [
  {
    roleName: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'
    roleDescription: 'Private DNS Zone Contributor | Lets you manage private DNS zone resources.'
    roleAssignmentDescription: 'AKS Managed Cluster can manage custom Private DNS Zone.'
  }
  {
    roleName: routeTableAdminRoleDefinition.name
    roleDescription: 'Route Table Administrator | View and edit properties of Route Tables.'
    roleAssignmentDescription: 'AKS Managed Cluster can manage custom Rouble Table.'
  }
]

resource aksManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in aksManagedIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, aksManagedIdentity.id, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Custom Role Definitions ====================================

var routeTableAdminRoleName = 'Route Table Administrator 2'

resource routeTableAdminRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(tenantId, resourceGroup().id, aksManagedIdentity.id, routeTableAdminRoleName)
  properties: {
    roleName: routeTableAdminRoleName
    description: 'View and edit properties of Route Tables.'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Network/routeTables/read'
          'Microsoft.Network/routeTables/write'
          'Microsoft.Network/routeTables/join/action'
          'Microsoft.Network/routeTables/routes/read'
          'Microsoft.Network/routeTables/routes/write'
          'Microsoft.Network/routeTables/routes/delete'
        ]
        notActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

// ==================================== Security Principals ====================================

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: aksManagedIdentityName
}

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
