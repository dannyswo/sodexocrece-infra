/**
 * Template: shared/group
 * Modules: N/A
 */

targetScope = 'subscription'

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

@description('Azure region.')
param location string = 'eastus2'

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Standard tags applied to all resources.')
param standardTags object = {
  ApplicationName: ''
  ApplicationOwner: ''
  ApplicationSponsor: ''
  TechnicalContact: ''
  Billing: ''
  Maintenance: ''
  EnvironmentType: ''
  Security: ''
  DeploymentDate: ''
  dd_organization: ''
}

// ==================================== Resources ====================================

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RG01'
  location: location
  properties: {
  }
  tags: standardTags
}
