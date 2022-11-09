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

@description('Standard name of the Jump Servers VNet.')
@minLength(4)
@maxLength(4)
param jumpServersVNetName string

@description('IP range or CIDR of the Jump Servers VNet.')
param jumpServersVNetAddressPrefix string

@description('Standard name of the Jump Servers Subnet.')
@minLength(4)
@maxLength(4)
param jumpServersSubnetName string

@description('IP range or CIDR of the Jump Servers Subnet.')
param jumpServersSubnetAddressPrefix string

@description('Standard name of the DevOps Agents VNet.')
@minLength(4)
@maxLength(4)
param devopsAgentsVNetName string

@description('IP range or CIDR of the DevOps Agents VNet.')
param devopsAgentsVNetAddressPrefix string

@description('Standard name of the Devops Agents Subnet.')
@minLength(4)
@maxLength(4)
param devopsAgentsSubnetName string

@description('IP range or CIDR of the Devops Agents Subnet.')
param devopsAgentsSubnetAddressPrefix string

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource definitions ====================================

// ==================================== VNets and Subnets ====================================

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
          networkSecurityGroup: {
            id: gatewayNSG.id
          }
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
          networkSecurityGroup: {
            id: appsNSG.id
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
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
          networkSecurityGroup: {
            id: endpointsNSG.id
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource jumpServersVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        jumpServersVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${jumpServersSubnetName}'
        properties: {
          addressPrefix: jumpServersSubnetAddressPrefix
          networkSecurityGroup: {
            id: jumpServersNSG.id
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource devopsAgentsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsVNetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        devopsAgentsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsSubnetName}'
        properties: {
          addressPrefix: devopsAgentsSubnetAddressPrefix
          networkSecurityGroup: {
            id: devopsAgentsNSG.id
          }
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

// ==================================== VNets Peerings ====================================

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

resource jumpServersAppsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP05'
  parent: jumpServersVNet
  properties: {
    remoteVirtualNetwork: {
      id: appsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource appsJumpServerVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP06'
  parent: appsVNet
  properties: {
    remoteVirtualNetwork: {
      id: jumpServersVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource jumpServersEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP07'
  parent: jumpServersVNet
  properties: {
    remoteVirtualNetwork: {
      id: endpointsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource endpointsJumpServersVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP08'
  parent: endpointsVNet
  properties: {
    remoteVirtualNetwork: {
      id: jumpServersVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource devopsAgentsAppsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP09'
  parent: devopsAgentsVNet
  properties: {
    remoteVirtualNetwork: {
      id: appsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource appsDevopsAgentsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP10'
  parent: appsVNet
  properties: {
    remoteVirtualNetwork: {
      id: devopsAgentsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource devopsAgentsEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP11'
  parent: devopsAgentsVNet
  properties: {
    remoteVirtualNetwork: {
      id: endpointsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource endpointsDevopsAgentsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP12'
  parent: endpointsVNet
  properties: {
    remoteVirtualNetwork: {
      id: devopsAgentsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

// ==================================== Network Security Groups (NSGs) ====================================

resource gatewayNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS01'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowInternetHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '80'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow Internet HTTP Inbound.'
        }
      }
      {
        name: 'AllowInternetHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          priority: 111
          description: 'Allow Internet HTTPS Inbound.'
        }
      }
      {
        name: 'AllowInternetAzurePortsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: '*'
          priority: 200
          description: 'Allow Internet HTTP Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource appsNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS02'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            gatewaySubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRange: '80'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow Gateway and Jump Servers HTTP Inbound.'
        }
      }
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            gatewaySubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          priority: 111
          description: 'Allow Gateway and Jump Servers HTTPS Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource endpointsNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS03'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            appsSubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRange: '80'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow Apps and Jump Servers HTTP Inbound.'
        }
      }
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            appsSubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          priority: 111
          description: 'Allow Apps and Jump Servers HTTPS Inbound.'
        }
      }
      {
        name: 'AllowSqlServerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            appsSubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRange: '1433'
          destinationAddressPrefix: '*'
          priority: 112
          description: 'Allow Apps and Jump Servers SQL Server Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource jumpServersNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS04'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowInternetRdpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '3389'
          destinationAddressPrefix: '*'
          priority: 120
          description: 'Allow Internet RDP Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource devopsAgentsNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS05'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowInternetRdpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '3389'
          destinationAddressPrefix: '*'
          priority: 120
          description: 'Allow Internet RDP Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

// ==================================== Outputs ====================================

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
  {
    id: jumpServersVNet.id
    name: jumpServersVNet.name
  }
  {
    id: devopsAgentsVNet.id
    name: devopsAgentsVNet.name
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
  {
    id: jumpServersVNet.properties.subnets[0].id
    name: jumpServersVNet.properties.subnets[0].name
  }
  {
    id: devopsAgentsVNet.properties.subnets[0].id
    name: devopsAgentsVNet.properties.subnets[0].name
  }
]

@description('ID of the NSG attached to the Applications VNet.')
output appsNSGId string = appsNSG.id

@description('Name of the NSG attached to the Applications VNet.')
output appsNSGName string = appsNSG.name
