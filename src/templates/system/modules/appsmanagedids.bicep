/**
 * Module: appsManagedIds
 * Depends on: N/A
 * Used by: system/mainSystem
 * Common resources: N/A
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

// ==================================== User-Assigned Managed Identities: Applications ====================================

resource app1ManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD04'
  location: location
  tags: standardTags
}

// ==================================== Outputs ====================================

@description('Principal ID of the Managed Identity of App 1.')
output app1ManagedIdentityId string = app1ManagedIdentity.properties.principalId

@description('Name of the Managed Identity of App 1.')
output app1ManagedIdentityName string = app1ManagedIdentity.name
