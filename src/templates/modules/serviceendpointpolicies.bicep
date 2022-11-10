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

@description('ID of the Key Vault.')
param keyVaultId string

@description('ID of the Storage Account for monitoring data.')
param monitoringDataStorageAccountId string

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource definitions ====================================

// ==================================== Service Endpoint Policies ====================================

resource keyVaultServiceEndpointPolicies 'Microsoft.Network/serviceEndpointPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-SE01'
  location: location
  properties: {
    serviceEndpointPolicyDefinitions: [
      {
        name: 'SE01-Definition1'
        properties: {
          service: 'Microsoft.KeyVault'
          description: 'Allow access to DevOps / shared Key Vault via Service Endpoint.'
          serviceResources: [
            keyVaultId
          ]
        }
      }
    ]
  }
  tags: standardTags
}

resource monitoringDataStorageServiceEndpointPolicies 'Microsoft.Network/serviceEndpointPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-SE02'
  location: location
  properties: {
    serviceEndpointPolicyDefinitions: [
      {
        name: 'SE02-Definition1'
        properties: {
          service: 'Microsoft.Storage'
          description: 'Access to Storage Account for monitoring data via Service Endpoint.'
          serviceResources: [
            monitoringDataStorageAccountId
          ]
        }
      }
    ]
  }
  tags: standardTags
}

// ==================================== Outputs ====================================

@description('ID of the Service Endpoint Policies to access Key Vault.')
output keyVaultServiceEndpointPoliciesId string = keyVaultServiceEndpointPolicies.id

@description('ID of the Service Endpoint Policies to access Storage Account for monitoring data.')
output monitoringDataStorageServiceEndpointPoliciesId string = monitoringDataStorageServiceEndpointPolicies.id
