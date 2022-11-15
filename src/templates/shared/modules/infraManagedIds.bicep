/**
 * Module: inframanagedids
 * Depends on: N/A
 * Used by: shared/mainShared
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
