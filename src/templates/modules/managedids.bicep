/**
 * Module: inframanagedids
 * Depends on: N/A
 * Used by: shared/main
 * Common resources: AD01 (agw), AD02 (appsdatastorage), AD03 (aks)
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Standard tags applied to all resources.')
param standardTags object

// ==================================== Resources ====================================

// ==================================== User-Assigned Managed Identities ====================================

resource appGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD01'
  location: location
  tags: standardTags
}

resource appsDataStorageManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD02'
  location: location
  tags: standardTags
}

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD03'
  location: location
  tags: standardTags
}

// ==================================== Custom Role Definitions ====================================

var routeTablesAdminActions = [
  'Microsoft.Network/routeTables/read'
  'Microsoft.Network/routeTables/write'
  'Microsoft.Network/routeTables/join/action'
  'Microsoft.Network/routeTables/routes/read'
  'Microsoft.Network/routeTables/routes/write'
  'Microsoft.Network/routeTables/routes/delete'
]

var routeTableAdminRoleName = 'Route Table Administrator'

resource routeTableAdminRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(resourceGroup().id, aksManagedIdentity.id, routeTableAdminRoleName)
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

// ==================================== Role Assignments ====================================

var appGatewayManagedIdentityRoleDefinitions = [
  {
    roleName: 'a4417e6f-fecd-4de8-b567-7b0420556985'
    roleDescription: 'Key Vault Certificates Officer | Perform any action on the certificates of a key vault.'
    roleAssignmentDescription: 'Access public certificate in the Key Vault from Application Gateway.'
  }
  {
    roleName: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
    roleDescription: 'Key Vault Secrets Officer | Perform any action on the secrets of a key vault'
    roleAssignmentDescription: 'Access secrets in the Key Vault from Application Gateway.'
  }
]

resource appGatewayManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appGatewayManagedIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, appGatewayManagedIdentity.id, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appGatewayManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

var appsDataStorageManagedIdentityRoleDefinitions = [
  {
    roleName: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
    roleDescription: 'Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.'
    roleAssignmentDescription: 'Access encryption key in the infrastructure Key Vault from applications data Storage Account.'
  }
]

resource appsDataStorageManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appsDataStorageManagedIdentityRoleDefinitions: {
  name: guid(resourceGroup().id, appsDataStorageManagedIdentity.id, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appsDataStorageManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

var aksManagedIdentityRoleDefinitions = [
  {
    roleName: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'
    roleDescription: 'Private DNS Zone Contributor | Lets you manage private DNS zone resources.'
    roleAssignmentDescription: 'Manage custom Private DNS Zone for AKS Managed Cluster.'
  }
  {
    roleName: routeTableAdminRoleDefinition.name
    roleDescription: 'Route Table Administrator | View and edit properties of Route Tables.'
    roleAssignmentDescription: 'Manage custom Rouble Table for AKS Managed Cluster.'
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

// ==================================== Outputs ====================================

@description('Principal ID of the Managed Identity of Application Gateway.')
output appGatewayManagedIdentityId string = appGatewayManagedIdentity.properties.principalId

@description('Name of the Managed Identity of Application Gateway.')
output appGatewayManagedIdentityName string = appGatewayManagedIdentity.name

@description('Principal ID of the Managed Identity of applications data Storage Account.')
output appsDataStorageManagedIdentityId string = appsDataStorageManagedIdentity.properties.principalId

@description('Name of the Managed Identity of applications data Storage Account.')
output appsDataStorageManagedIdentityName string = appsDataStorageManagedIdentity.name

@description('Principal ID of the Managed Identity of AKS Managed Cluster.')
output aksManagedIdentityId string = aksManagedIdentity.properties.principalId

@description('Name of the Managed Identity of AKS Managed Cluster.')
output aksManagedIdentityName string = aksManagedIdentity.name
