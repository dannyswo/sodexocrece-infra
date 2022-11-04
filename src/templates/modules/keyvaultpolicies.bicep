@description('Name of the Key Vault.')
param keyVaultName string

@description('ID of the AAD Tenant of the Principal IDs.')
param tenantId string = subscription().tenantId

@description('ID of the Managed Identity used by Application Gateway.')
param appGatewayPrincipalId string

@description('ID of the Managed Identity used by Application Data Storage Account.')
param appsDataStorageAccountPrincipalId string

@description('List of AAD Principal IDs allowed to manage Key Vault secrets.')
param principalIds array = []

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

var appGatewayAccessPolicy = {
  objectId: appGatewayPrincipalId
  tenantId: tenantId
  permissions: {
    certificates: [
      'get'
      'import'
      'list'
      'listissuers'
    ]
  }
}

var appsDataStorageAccountAccessPolicy = {
  objectId: appsDataStorageAccountPrincipalId
  tenantId: tenantId
  permissions: {
    keys: [
      'get'
      'encrypt'
      'decrypt'
      'list'
      'import'
      'getrotationpolicy'
    ]
  }
}

var additionalAccessPolicies = [for principalId in principalIds: {
  objectId: principalId
  tenantId: tenantId
  permissions: {
    secrets: [
      'get'
      'list'
    ]
  }
}]

var azureServicesAccessPolicies = [
  appGatewayAccessPolicy
  appsDataStorageAccountAccessPolicy
]

var accessPolicies = concat(azureServicesAccessPolicies, additionalAccessPolicies)

resource appGatewayAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: accessPolicies
  }
}
