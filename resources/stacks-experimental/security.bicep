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

@description('Create network resources defined in the network module.')
param enableNetwork bool = false

@description('Name of the Gateway VNet. Must be defined when enableNetwork is false.')
param gatewayVNetName string

@description('Name of the Applications VNet. Must be defined when enableNetwork is false.')
param appsVNetName string

@description('Name of the Endpoints VNet. Must be defined when enableNetwork is false.')
param endpointsVNetName string

@description('Name of the Endpoints Subnet. Must be defined when enableNetwork is false.')
param endpointsSubnetName string

@description('Name of the Jump Servers VNet. Must be defined when enableNetwork is false.')
param jumpServersVNetName string

@description('Name of the DevOps Agents VNet. Must be defined when enableNetwork is false.')
param devopsAgentsVNetName string

@description('Create Private Endpoints for the required modules like keyvault, appdatastorage, database and acr.')
param enablePrivateEndpoints bool = true

@description('Private IP of the Key Vault\'s Private Endpoint.')
param keyVaultPEPrivateIPAddress string

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
param standardTags object = resourceGroup().tags

param keyVaultNameSuffix string

module keyVaultModule '../modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
    env: env
    keyVaultNameSuffix: keyVaultNameSuffix
    standardTags: standardTags
  }
}

var selectedEndpointsSubnetName = endpointsSubnetName
var selectedLinkedVNetNames = (enableNetwork) ? [
  gatewayVNetName
  appsVNetName
  endpointsVNetName
] : [
  gatewayVNetName
  appsVNetName
  endpointsVNetName
  jumpServersVNetName
  devopsAgentsVNetName
]

module keyVaultPrivateEndpointModule '../modules/privateendpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'keyVaultPrivateEndpointModule'
  params: {
    location: location
    env: env
    privateEndpointName: 'PE02'
    subnetName: selectedEndpointsSubnetName
    privateIPAddresses: [ keyVaultPEPrivateIPAddress ]
    serviceId: keyVaultModule.outputs.keyVaultId
    groupId: 'vault'
    linkedVNetNames: selectedLinkedVNetNames
    standardTags: standardTags
  }
}
