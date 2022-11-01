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

@description('Standard name of the Gateway VNet.')
@minLength(3)
@maxLength(3)
param gatewayVNetName string

@description('IP range or CIDR of the Gateway VNet.')
@metadata({
  example: '10.169.72.0/21'
})
param gatewayVNetAddressPrefix string

@description('Standard name of the Gateway Subnet.')
@minLength(3)
@maxLength(3)
param gatewaySubnetName string

@description('IP range or CIDR of the Gateway Subnet.')
@metadata({
  example: '10.169.72.64/27'
})
param gatewaySubnetAddressPrefix string

@description('Standard name of the Applications VNet.')
@minLength(3)
@maxLength(3)
param appsVNetName string

@description('IP range or CIDR of the Applications VNet.')
@metadata({
  example: '10.169.72.0/21'
})
param appsVNetAddressPrefix string

@description('Standard name of the Applications Subnet.')
@minLength(3)
@maxLength(3)
param appsSubnetName string

@description('IP range or CIDR of the Applications Subnet.')
@metadata({
  example: '10.169.72.64/27'
})
param appsSubnetAddressPrefix string

@description('Standard name of the Endpoints VNet.')
@minLength(3)
@maxLength(3)
param endpointsVNetName string

@description('IP range or CIDR of the Endpoints VNet.')
@metadata({
  example: '10.169.72.0/21'
})
param endpointsVNetAddressPrefix string

@description('Standard name of the Endpoints Subnet.')
@minLength(3)
@maxLength(3)
param endpointsSubnetName string

@description('IP range or CIDR of the Endpoints Subnet.')
@metadata({
  example: '10.169.72.64/27'
})
param endpointsSubnetAddressPrefix string

resource gatewayVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-${gatewayVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        gatewayVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${environment}-${gatewaySubnetName}'
        properties: {
          addressPrefix: gatewaySubnetAddressPrefix
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource appsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-${appsVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        appsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${environment}-${appsSubnetName}'
        properties: {
          addressPrefix: appsSubnetAddressPrefix
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource endpointsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-${endpointsVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        endpointsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${environment}-${endpointsSubnetName}'
        properties: {
          addressPrefix: endpointsSubnetAddressPrefix
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource gatewayAppsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-VP01'
  parent: gatewayVNet
  properties: {
    remoteVirtualNetwork: {
      id: appsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource appsEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-VP02'
  parent: appsVNet
  properties: {
    remoteVirtualNetwork: {
      id: endpointsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

@description('IDs and names of the created VNets.')
@metadata({
  id: 'ID of the VNet.'
  name: 'Standard name of the VNet.'
  example: [
    {
      id: '/vnet/abc'
      name: 'BRS-MEX-USE2-CRECESDX-DEV-VN01'
    }
  ]
})
output vnets array = [
  {
    id: gatewayVNet.id
    name: gatewayVNet.name
  }
  {
    id: appsVNet.id
    name: appsVNet.name
  }
  {
    id: endpointsVNet.id
    name: endpointsVNet.name
  }
]

@description('IDs and names of the created Subnets.')
@metadata({
  id: 'ID of the Subnet.'
  name: 'Standard name of the Subnet.'
  example: [
    {
      id: '/vnet/abc/subnet/123'
      name: 'BRS-MEX-USE2-CRECESDX-DEV-SN01'
    }
  ]
})
output subnets array = [
  {
    id: gatewayVNet.properties.subnets[0].id
    name: gatewayVNet.properties.subnets[0].name
  }
  {
    id: appsVNet.properties.subnets[0].id
    name: appsVNet.properties.subnets[0].name
  }
  {
    id: endpointsVNet.properties.subnets[0].id
    name: endpointsVNet.properties.subnets[0].name
  }
]
