@description('Azure region to deploy the Private Endpoint.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param environment string

@description('Standard name of the Private Endpoint.')
@minLength(3)
@maxLength(3)
param privateEndpointName string

@description('ID of the Subnet where Private Endpoint will be deployed.')
param subnetId string

@description('Private IP address of the Private Endpoint.')
param privateEndpointIPAddress string

@description('ID of the service connected to the Private Endpoint.')
param serviceId string

@description('Subresource of the Private Endpoint.')
@allowed([
  'vault'
  'registry'
  'storageAccount'
  'server'
])
param groupId string

var requiredMemberMap = {
  vault: 'default'
  registry: 'registry'
  storageAccount: 'default'
  server: 'default'
}

var memberName = requiredMemberMap[groupId]

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-${privateEndpointName}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: 'BRS-MEX-USE2-CRECESDX-${environment}-${privateEndpointName}-NIC'
    ipConfigurations: [
      {
        name: '${privateEndpointName}-ipconfig'
        properties: {
          groupId: groupId
          memberName: memberName
          privateIPAddress: privateEndpointIPAddress
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-connection'
        properties: {
          privateLinkServiceId: serviceId
          groupIds: [ groupId ]
        }
      }
    ]
  }
}
