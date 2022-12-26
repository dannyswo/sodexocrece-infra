/**
 * Module: managed-identities
 * Depends on: N/A
 * Used by: shared/main-shared
 * Common resources: AD01 (app-gateway), AD02 (apps-storage-account), AD03 (aks)
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

// ==================================== User-Assigned Managed Identities: Infrastructure Services ====================================

resource appGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD01'
  location: location
  tags: standardTags
}

resource appsStorageAccountManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD02'
  location: location
  tags: standardTags
}

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD03'
  location: location
  tags: standardTags
}

resource containerApp1ManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD04'
  location: location
  tags: standardTags
}

// ==================================== Outputs ====================================

@description('Principal ID of the Managed Identity of Application Gateway.')
output appGatewayManagedIdentityPrincipalId string = appGatewayManagedIdentity.properties.principalId

@description('Name of the Managed Identity of Application Gateway.')
output appGatewayManagedIdentityName string = appGatewayManagedIdentity.name

@description('Principal ID of the Managed Identity of applications Storage Account.')
output appsStorageAccountManagedIdentityPrincipalId string = appsStorageAccountManagedIdentity.properties.principalId

@description('Name of the Managed Identity of applications Storage Account.')
output appsStorageAccountManagedIdentityName string = appsStorageAccountManagedIdentity.name

@description('Principal ID of the Managed Identity of AKS Managed Cluster.')
output aksManagedIdentityPrincipalId string = aksManagedIdentity.properties.principalId

@description('Name of the Managed Identity of AKS Managed Cluster.')
output aksManagedIdentityName string = aksManagedIdentity.name

@description('Principal ID of the Managed Identity of container application 1.')
output containerApp1ManagedIdentityPrincipalId string = containerApp1ManagedIdentity.properties.principalId

@description('Name of the Managed Identity of container application 1.')
output containerApp1ManagedIdentityName string = containerApp1ManagedIdentity.name

@description('Client ID of the Managed Identity of container application 1.')
output containerApp1ManagedIdentityClientId string = containerApp1ManagedIdentity.properties.clientId
