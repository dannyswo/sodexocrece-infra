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

@description('Principal ID of the system administrator.')
param administratorPrincipalId string

@description('Name of the Managed Identity of AKS Managed Cluster.')
param aksManagedIdentityName string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Role Assignments: Administrator ====================================

var administratorRoleDefinitions = [
  {
    roleName: azureFeatureManagerRoleDefinition.name
    roleDescription: 'Azure Features Manager | Read and register Azure Features and Feature Providers.'
    roleAssignmentDescription: 'System administrator can manage Azure Features.'
    scope: 'Subscription'
  }
  {
    roleName: 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
    roleDescription: 'Azure Kubernetes Service RBAC Cluster Admin | Lets you manage all resources in the cluster'
    roleAssignmentDescription: 'System administrator can manage AKS Managed Cluster objects.'
    scope: 'ResourceGroup'
  }
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data'
    roleAssignmentDescription: 'System administrator can access Storage Account Blob data.'
    scope: 'ResourceGroup'
  }
  {
    roleName: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    roleDescription: 'Owner | Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.'
    roleAssignmentDescription: 'System administrator can modify resources in the Resource Group and assign roles.'
    scope: 'ResourceGroup'
  }
]

resource administratorRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in administratorRoleDefinitions: {
  name: guid((roleDefinition.scope == 'ResourceGroup') ? resourceGroup().id : subscription().id, administratorPrincipalId, roleDefinition.roleName)
  scope: (roleDefinition.scope == 'ResourceGroup') ? resourceGroup() : subscription()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: administratorPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'User'
  }
}]

// ==================================== Role Assignments: AKS Managed Cluster Managed Identity ====================================

var aksManagedIdentityRoleDefinitions = [
  {
    roleName: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'
    roleDescription: 'Private DNS Zone Contributor | Lets you manage private DNS zone resources.'
    roleAssignmentDescription: 'AKS Managed Cluster can manage custom Private DNS Zone.'
    scope: 'ResourceGroup'
  }
  {
    roleName: routeTableAdminRoleDefinition.name
    roleDescription: 'Route Table Administrator | View and edit properties of Route Tables.'
    roleAssignmentDescription: 'AKS Managed Cluster can manage custom Rouble Table.'
    scope: 'ResourceGroup'
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

var azureFeatureManagerActions = [
  'Microsoft.Features/features/read'
  'Microsoft.Features/providers/features/read'
  'Microsoft.Features/providers/features/register/action'
]

var azureFeaturesManagerRoleName = 'Azure Features Manager 2'

resource azureFeatureManagerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(tenantId, resourceGroup().id, administratorPrincipalId, azureFeaturesManagerRoleName)
  properties: {
    roleName: azureFeaturesManagerRoleName
    description: 'Read and register Azure Features and Feature Providers.'
    type: 'customRole'
    permissions: [
      {
        actions: azureFeatureManagerActions
        notActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

var routeTablesAdminActions = [
  'Microsoft.Network/routeTables/read'
  'Microsoft.Network/routeTables/write'
  'Microsoft.Network/routeTables/join/action'
  'Microsoft.Network/routeTables/routes/read'
  'Microsoft.Network/routeTables/routes/write'
  'Microsoft.Network/routeTables/routes/delete'
]

var routeTableAdminRoleName = 'Route Table Administrator 2'

resource routeTableAdminRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(tenantId, resourceGroup().id, aksManagedIdentity.id, routeTableAdminRoleName)
  properties: {
    roleName: routeTableAdminRoleName
    description: 'View and edit properties of Route Tables.'
    type: 'customRole'
    permissions: [
      {
        actions: routeTablesAdminActions
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
