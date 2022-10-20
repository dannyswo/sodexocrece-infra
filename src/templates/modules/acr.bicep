@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

var cloudProvider = 'AZ'
var cloudRegion = 'US'
var cloudService = 'ACR'
var randomString = take(uniqueString(resourceGroup().id),3)
resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: '${cloudProvider}${cloudRegion}${cloudService}1${randomString}620'
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
