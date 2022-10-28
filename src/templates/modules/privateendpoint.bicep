param location string = resourceGroup().location
param subnetId string
param serviceId string
param groupIds array
param privateEndpointName string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: serviceId
          groupIds: groupIds
        }
      }
    ]
  }
  // dependsOn: [
  //   vnet
  // ]
}
