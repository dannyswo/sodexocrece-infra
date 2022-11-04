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

@description('Standard name of the Gateway VNet.')
@minLength(4)
@maxLength(4)
param gatewayVNetName string

@description('IP range or CIDR of the Gateway VNet.')
param gatewayVNetAddressPrefix string

@description('Standard name of the Gateway Subnet.')
@minLength(4)
@maxLength(4)
param gatewaySubnetName string

@description('IP range or CIDR of the Gateway Subnet.')
param gatewaySubnetAddressPrefix string

@description('Standard name of the Applications VNet.')
@minLength(4)
@maxLength(4)
param appsVNetName string

@description('IP range or CIDR of the Applications VNet.')
param appsVNetAddressPrefix string

@description('Standard name of the Applications Subnet.')
@minLength(4)
@maxLength(4)
param appsSubnetName string

@description('IP range or CIDR of the Applications Subnet.')
param appsSubnetAddressPrefix string

@description('Standard name of the Endpoints VNet.')
@minLength(4)
@maxLength(4)
param endpointsVNetName string

@description('IP range or CIDR of the Endpoints VNet.')
param endpointsVNetAddressPrefix string

@description('Standard name of the Endpoints Subnet.')
@minLength(4)
@maxLength(4)
param endpointsSubnetName string

@description('IP range or CIDR of the Endpoints Subnet.')
param endpointsSubnetAddressPrefix string

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

resource gatewayVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${gatewayVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        gatewayVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${gatewaySubnetName}'
        properties: {
          addressPrefix: gatewaySubnetAddressPrefix
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource appsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${appsVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        appsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${appsSubnetName}'
        properties: {
          addressPrefix: appsSubnetAddressPrefix
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource appsNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS01'
  location: location
  dependsOn: [
    appsVNet
  ]
  properties: {
    securityRules: [
      {
        name: 'AllowHttp'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '80'
          sourceAddressPrefix: '*'
          destinationPortRange: '80'
          destinationAddressPrefix: '*'
          priority: 10
          description: 'Allow HTTP from anywhere.'
        }
      }
      {
        name: 'AllowHttps'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '443'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          priority: 10
          description: 'Allow HTTPS from anywhere.'
        }
      }
    ]
  }
  tags: standardTags
}

resource endpointsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        endpointsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsSubnetName}'
        properties: {
          addressPrefix: endpointsSubnetAddressPrefix
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource gatewayAppsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP01'
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

resource appsGatewayVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP03'
  parent: appsVNet
  properties: {
    remoteVirtualNetwork: {
      id: gatewayVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource appsEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP02'
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

resource endpointsAppsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP04'
  parent: endpointsVNet
  properties: {
    remoteVirtualNetwork: {
      id: appsVNet.id
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

@description('ID of the Applications VNet NSG.')
output appsNSGId string = appsNSG.id

@description('Name of the Applications VNet NSG.')
output appsNSGName string = appsNSG.name
