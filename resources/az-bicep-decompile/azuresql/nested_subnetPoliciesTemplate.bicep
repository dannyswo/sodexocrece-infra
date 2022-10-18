param variables_privateEndpointApi ? /* TODO: fill in correct type */
param privateEndpointVnetName string
param privateEndpointSubnetName string
param privateEndpointLocation string

resource privateEndpointVnetName_privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@[parameters(\'variables_privateEndpointApi\')]' = {
  name: '${privateEndpointVnetName}/${privateEndpointSubnetName}'
  location: privateEndpointLocation
  properties: {
    privateEndpointNetworkPolicies: 'Disabled'
  }
}