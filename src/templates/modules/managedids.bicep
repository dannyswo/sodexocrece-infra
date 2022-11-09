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

// ==================================== Resource definitions ====================================

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

// ==================================== Role Assignments ====================================

var appGatewayManagedIdentityRoleDefinitions = [
  {
    roleId: 'a4417e6f-fecd-4de8-b567-7b0420556985'
    roleDescription: 'Key Vault Certificates Officer | Perform any action on the certificates of a key vault.'
    roleAssignmentDescription: 'Access public certificate in the Key Vault from Application Gateway.'
  }
]

resource appGatewayManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appGatewayManagedIdentityRoleDefinitions: {
  name: guid('${appGatewayManagedIdentity.name}-${roleDefinition.roleId}')
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appGatewayManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleId)
    principalType: 'ServicePrincipal'
  }
}]

var appsDataStorageManagedIdentityRoleDefinitions = [
  {
    roleId: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
    roleDescription: 'Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.'
    roleAssignmentDescription: 'Access encryption key in the Key Vault from Application Data Storage Account.'
  }
]

resource appsDataStorageManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in appsDataStorageManagedIdentityRoleDefinitions: {
  name: guid('${appsDataStorageManagedIdentity.name}-${roleDefinition.roleId}')
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: appsDataStorageManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleId)
    principalType: 'ServicePrincipal'
  }
}]

var aksManagedIdentityRoleDefinitions = [
  {
    roleId: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f'
    roleDescription: 'Private DNS Zone Contributor | Lets you manage private DNS zone resources.'
    roleAssignmentDescription: 'Manage custom Private DNS Zone for AKS Managed Cluster.'
  }
]

resource aksManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in aksManagedIdentityRoleDefinitions: {
  name: guid('${aksManagedIdentity.name}-${roleDefinition.roleId}')
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: aksManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleId)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Outputs ====================================

output appGatewayManagedIdentityId string = appGatewayManagedIdentity.properties.principalId

output appGatewayManagedIdentityName string = appGatewayManagedIdentity.name

output appsDataStorageManagedIdentityId string = appsDataStorageManagedIdentity.properties.principalId

output appsDataStorageManagedIdentityName string = appsDataStorageManagedIdentity.name

output aksManagedIdentityId string = aksManagedIdentity.properties.principalId

output aksManagedIdentityName string = aksManagedIdentity.name
