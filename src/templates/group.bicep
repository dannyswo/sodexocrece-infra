targetScope = 'subscription'

@description('Azure region to deploy the Resource Group.')
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
})
param standardTags object

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RG01'
  location: location
  properties: {
  }
  tags: standardTags
}
