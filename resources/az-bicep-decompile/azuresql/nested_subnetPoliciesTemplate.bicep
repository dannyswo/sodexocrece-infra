param privateEndpointVnetName string
param privateEndpointSubnetName string
param privateEndpointLocation string

resource privateEndpointVnetName_privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: '${privateEndpointVnetName}/${privateEndpointSubnetName}'
  location: privateEndpointLocation
  properties: {
    privateEndpointNetworkPolicies: 'Disabled'
  }
}
