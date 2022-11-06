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
param standardTags object = resourceGroup().tags

// Resource definitions

resource appGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD01'
  location: location
  tags: standardTags
}

@description('ID of the Role Definition: Key Vault Certificates Officer | Perform any action on the certificates of a key vault.')
var keyVaultCertificatesOfficerRoleDefinitionId = 'a4417e6f-fecd-4de8-b567-7b0420556985'

resource appGatewayManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appGatewayManagedIdentity.name)
  scope: resourceGroup()
  properties: {
    description: 'Access public certificate in the Key Vault from Application Gateway.'
    principalId: appGatewayManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultCertificatesOfficerRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

resource appsDataStorageManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD03'
  location: location
  tags: standardTags
}

@description('ID of the Role Definition: Key Vault Crypto Service Encryption User | Read metadata of keys and perform wrap/unwrap operations.')
var keyVaultCryptoEncryptionUserRoleDefinitionId = 'e147488a-f6f5-4113-8e2d-b22465e65bf6'

resource appsDataStorageManagedIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appsDataStorageManagedIdentity.name)
  scope: resourceGroup()
  properties: {
    description: 'Access encryption key in the Key Vault from Application Data Storage Account.'
    principalId: appsDataStorageManagedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultCryptoEncryptionUserRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

@description('ID of the Role Definition: Key Vault Contributor | Lets you manage key vaults.')
var keyVaultAdministratorRoleDefinitionId = 'f25e0fa2-a7c8-4377-a976-54943a77a395'

resource devopsEngineerRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('danny.zamorano@softwareone.com')
  scope: resourceGroup()
  properties: {
    description: 'DevOps engineer can execute management operations on Key Vault.'
    principalId: '40c2e922-9fb6-4186-a53f-44439c85a9df'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdministratorRoleDefinitionId)
    principalType: 'User'
  }
}

output appGatewayManagedIdentityId string = appGatewayManagedIdentity.properties.principalId

output appGatewayManagedIdentityName string = appGatewayManagedIdentity.name

output appsDataStorageManagedIdentityId string = appsDataStorageManagedIdentity.properties.principalId

output appsDataStorageManagedIdentityName string = appsDataStorageManagedIdentity.name

output ownerPrincipalId string = '40c2e922-9fb6-4186-a53f-44439c85a9df'
