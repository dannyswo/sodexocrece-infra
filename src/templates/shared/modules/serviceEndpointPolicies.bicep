/**
 * Module: serviceEndpointPolicies
 * Depends on: N/A
 * Used by: system/mainShared
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

@description('ID of the monitoring data Storage Account.')
param monitoringDataStorageAccountId string

@description('ID of the infrastructure Key Vault.')
param infraKeyVaultId string

// ==================================== Resources ====================================

// ==================================== Service Endpoint Policies ====================================

resource monitoringDataStorageServiceEndpointPolicies 'Microsoft.Network/serviceEndpointPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-SE02'
  location: location
  properties: {
    serviceEndpointPolicyDefinitions: [
      {
        name: 'SE02-Definition1'
        properties: {
          service: 'Microsoft.Storage'
          description: 'Access to monitoring data Storage Account via Service Endpoint.'
          serviceResources: [
            monitoringDataStorageAccountId
          ]
        }
      }
    ]
  }
  tags: standardTags
}

resource infraKeyVaultServiceEndpointPolicies 'Microsoft.Network/serviceEndpointPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-SE01'
  location: location
  properties: {
    serviceEndpointPolicyDefinitions: [
      {
        name: 'SE01-Definition1'
        properties: {
          service: 'Microsoft.KeyVault'
          description: 'Allow access to infrastructure Key Vault via Service Endpoint.'
          serviceResources: [
            infraKeyVaultId
          ]
        }
      }
    ]
  }
  tags: standardTags
}

// ==================================== Outputs ====================================

@description('ID of the Service Endpoint Policies to access infrastructure Key Vault.')
output infraKeyVaultServiceEndpointPoliciesId string = infraKeyVaultServiceEndpointPolicies.id

@description('ID of the Service Endpoint Policies to access monitoring data Storage Account.')
output monitoringDataStorageServiceEndpointPoliciesId string = monitoringDataStorageServiceEndpointPolicies.id
