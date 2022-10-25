@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Premium'
param randomString string
param randomNumber string
var cloudProvider = 'az'
var cloudRegion = 'mx'
var cloudService = 'acr'

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: '${cloudProvider}${cloudRegion}${cloudService}1${randomString}${randomNumber}'
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Disabled'
  }
}

// @description('Output the login server property for later use')
// output loginServer string = acrResource.properties.loginServer
