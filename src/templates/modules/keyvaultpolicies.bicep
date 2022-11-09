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

// ==================================== Resource definitions ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

var appGatewayAccessPolicy = {
  objectId: appGatewayPrincipalId
  tenantId: tenantId
  permissions: {
    certificates: [
      'all'
    ]
  }
}

var appsDataStorageAccountAccessPolicy = {
  objectId: appsDataStorageAccountPrincipalId
  tenantId: tenantId
  permissions: {
    keys: [
      'all'
    ]
  }
}

var azureServicesAccessPolicies = [
  appGatewayAccessPolicy
  appsDataStorageAccountAccessPolicy
]

var applicationsAccessPolicies = [for principalId in principalIds: {
  objectId: principalId
  tenantId: tenantId
  permissions: {
    secrets: [
      'get'
      'list'
    ]
  }
}]

var additionalAccessPolicies = [
  {
    objectId: '40c2e922-9fb6-4186-a53f-44439c85a9df'
    tenantId: tenantId
    permissions: {
      certificates: [
        'all'
      ]
      keys: [
        'all'
      ]
      secrets: [
        'all'
      ]
    }
  }
]

var accessPolicies = concat(azureServicesAccessPolicies, applicationsAccessPolicies, additionalAccessPolicies)

resource appGatewayAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: accessPolicies
  }
}
