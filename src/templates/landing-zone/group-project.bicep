/**
 * Template: landing-zone/group-project
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
@metadata({
  AllowShutdown: 'True (for non-prod environments), False (for prod environments)'
  ApplicationName: 'BRS.LATAM.MX.Crececonsdx'
  ApplicationOwner: 'ApplicationOwner'
  ApplicationSponsor: 'ApplicationSponsor'
  dd_organization: 'MX (only for prod environments)'
  env: 'dev | uat | prd'
  EnvironmentType: 'DEV | UAT | PRD'
  Maintainer: 'SoftwareONE'
  Maintenance: '{ ... } (maintenance standard JSON)'
  Security: '{ ... } (security standard JSON generated in Palantir)'
  DeploymentDate: 'YYY-MM-DDTHHMM UTC (autogenatered)'
  stack: 'Merchant'
  TechnicalContact: 'TechnicalContact'
})
param standardTags object

// ==================================== Resources ====================================

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RG01'
  location: location
  properties: {
  }
  tags: standardTags
}
