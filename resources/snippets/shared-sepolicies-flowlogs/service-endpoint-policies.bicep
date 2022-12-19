/**
 * Module: service-endpoint-policies
 * Depends on: N/A
 * Used by: system/main-shared
 * Resources: N/A
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

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@description('ID of the monitoring Storage Account.')
param monitoringStorageAccountId string

@description('ID of the Key Vault.')
param keyVaultId string

// ==================================== Resources ====================================

// ==================================== Service Endpoint Policies ====================================

resource monitoringStorageAccountServiceEndpointPolicies 'Microsoft.Network/serviceEndpointPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-SE01'
  location: location
  properties: {
    serviceEndpointPolicyDefinitions: [
      {
        name: 'SE02-Definition1'
        properties: {
          service: 'Microsoft.Storage'
          description: 'Allow access to monitoring Storage Account via Service Endpoint.'
          serviceResources: [
            monitoringStorageAccountId
          ]
        }
      }
    ]
  }
  tags: standardTags
}

resource keyVaultServiceEndpointPolicies 'Microsoft.Network/serviceEndpointPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-SE02'
  location: location
  properties: {
    serviceEndpointPolicyDefinitions: [
      {
        name: 'SE01-Definition1'
        properties: {
          service: 'Microsoft.KeyVault'
          description: 'Allow access to Key Vault via Service Endpoint.'
          serviceResources: [
            keyVaultId
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

@description('ID of the Service Endpoint Policies to access monitoring Storage Account.')
output monitoringStorageAccountServiceEndpointPoliciesId string = monitoringStorageAccountServiceEndpointPolicies.id
