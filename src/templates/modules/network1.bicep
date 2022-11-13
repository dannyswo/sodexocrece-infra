/**
 * Module: network1
 * Depends on: N/A
 * Used by: system/main
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

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

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@description('Suffix of the Gateway VNet name.')
@minLength(4)
@maxLength(4)
param gatewayVNetNameSuffix string

@description('IP range or CIDR of the Gateway VNet.')
param gatewayVNetAddressPrefix string

@description('Suffix of the Gateway Subnet name.')
@minLength(4)
@maxLength(4)
param gatewaySubnetNameSuffix string

@description('IP range or CIDR of the Gateway Subnet.')
param gatewaySubnetAddressPrefix string

@description('Suffix of the Applications VNet name.')
@minLength(4)
@maxLength(4)
param appsVNetNameSuffix string

@description('IP range or CIDR of the Applications VNet.')
param appsVNetAddressPrefix string

@description('Suffix of the Applications Subnet name.')
@minLength(4)
@maxLength(4)
param appsSubnetNameSuffix string

@description('IP range or CIDR of the Applications Subnet.')
param appsSubnetAddressPrefix string

@description('Suffix name of the Endpoints VNet name.')
@minLength(4)
@maxLength(4)
param endpointsVNetNameSuffix string

@description('IP range or CIDR of the Endpoints VNet.')
param endpointsVNetAddressPrefix string

@description('Suffix of the Endpoints Subnet name.')
@minLength(4)
@maxLength(4)
param endpointsSubnetNameSuffix string

@description('IP range or CIDR of the Endpoints Subnet.')
param endpointsSubnetAddressPrefix string

@description('Suffix name of the Jump Servers VNet name.')
@minLength(4)
@maxLength(4)
param jumpServersVNetNameSuffix string

@description('IP range or CIDR of the Jump Servers VNet.')
param jumpServersVNetAddressPrefix string

@description('Suffix of the Jump Servers Subnet name.')
@minLength(4)
@maxLength(4)
param jumpServersSubnetNameSuffix string

@description('IP range or CIDR of the Jump Servers Subnet.')
param jumpServersSubnetAddressPrefix string

@description('Suffix of the DevOps Agents VNet name.')
@minLength(4)
@maxLength(4)
param devopsAgentsVNetNameSuffix string

@description('IP range or CIDR of the DevOps Agents VNet.')
param devopsAgentsVNetAddressPrefix string

@description('Suffix of the Devops Agents Subnet name.')
@minLength(4)
@maxLength(4)
param devopsAgentsSubnetNameSuffix string

@description('IP range or CIDR of the Devops Agents Subnet.')
param devopsAgentsSubnetAddressPrefix string

@description('Enable custom Route Table for AKS attached to Gateway and Apps VNet.')
param enableCustomRouteTable bool

@description('Enable Key Vault Service Endpoint on Gateway and Apps Subnet.')
param enableKeyVaultServiceEndpoint bool

@description('Enable Storage Account Service Endpoint on Gateway and Apps Subnet.')
param enableStorageAccountServiceEndpoint bool

@description('Enable Azure SQL Database Service Endpoint on Apps Subnet.')
param enableSqlDatabaseServiceEndpoint bool

@description('Enable Container Registry Service Endpoint on Apps Subnet.')
param enableContainerRegistryServiceEndpoint bool

// ==================================== Resources ====================================

// ==================================== VNets and Subnets ====================================

var serviceEndpointDefinitions = {
  keyVault: {
    locations: [ location ]
    service: 'Microsoft.KeyVault'
  }
  storageAccount: {
    locations: [ location ]
    service: 'Microsoft.Storage'
  }
  sql: {
    locations: [ location ]
    service: 'Microsoft.Sql'
  }
  containerRegistry: {
    locations: [ location ]
    service: 'Microsoft.ContainerRegistry'
  }
}

var gatewaySubnetServiceEndpoints0 = (enableKeyVaultServiceEndpoint) ? [ serviceEndpointDefinitions.keyVault ] : []
var gatewaySubnetServiceEndpoints = (enableStorageAccountServiceEndpoint) ? concat(gatewaySubnetServiceEndpoints0, [ serviceEndpointDefinitions.storageAccount ]) : gatewaySubnetServiceEndpoints0

var appsSubnetServiceEndpoints0 = (enableKeyVaultServiceEndpoint) ? [ serviceEndpointDefinitions.keyVault ] : []
var appsSubnetServiceEndpoints1 = (enableStorageAccountServiceEndpoint) ? concat(appsSubnetServiceEndpoints0, [ serviceEndpointDefinitions.storageAccount ]) : appsSubnetServiceEndpoints0
var appsSubnetServiceEndpoints2 = (enableSqlDatabaseServiceEndpoint) ? concat(appsSubnetServiceEndpoints1, [ serviceEndpointDefinitions.sql ]) : appsSubnetServiceEndpoints1
var appsSubnetServiceEndpoints = (enableContainerRegistryServiceEndpoint) ? concat(appsSubnetServiceEndpoints2, [ serviceEndpointDefinitions.containerRegistry ]) : appsSubnetServiceEndpoints2

resource gatewayVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${gatewayVNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        gatewayVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${gatewaySubnetNameSuffix}'
        properties: {
          addressPrefix: gatewaySubnetAddressPrefix
          networkSecurityGroup: {
            id: gatewayNSG.id
          }
          routeTable: (enableCustomRouteTable) ? {
            id: aksCustomRouteTable.id
          } : null
          serviceEndpoints: gatewaySubnetServiceEndpoints
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource appsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${appsVNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        appsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${appsSubnetNameSuffix}'
        properties: {
          addressPrefix: appsSubnetAddressPrefix
          networkSecurityGroup: {
            id: appsNSG.id
          }
          routeTable: (enableCustomRouteTable) ? {
            id: aksCustomRouteTable.id
          } : null
          serviceEndpoints: appsSubnetServiceEndpoints
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource endpointsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        endpointsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsSubnetNameSuffix}'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        jumpServersVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${jumpServersSubnetNameSuffix}'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsVNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        devopsAgentsVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsSubnetNameSuffix}'
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

resource gatewayEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP03'
  parent: gatewayVNet
  properties: {
    remoteVirtualNetwork: {
      id: endpointsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource endpointsGatewayVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP04'
  parent: endpointsVNet
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP05'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP06'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP07'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP08'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP09'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP10'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP11'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP12'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP13'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP14'
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
          description: 'Allow Internet Azure Ports Inbound.'
        }
      }
      {
        name: 'AllowGatewayManagerAzurePortsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: '*'
          priority: 201
          description: 'Allow GatewayManager Azure Ports Inbound.'
        }
      }
      {
        name: 'AllowInternetHttpOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '80'
          destinationAddressPrefix: 'Internet'
          priority: 110
          description: 'Allow Internet HTTP Inbound.'
        }
      }
      {
        name: 'AllowInternetHttpsOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'Internet'
          priority: 111
          description: 'Allow Internet HTTPS Inbound.'
        }
      }
      {
        name: 'AllowGatewayManagerAzurePortsOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: 'GatewayManager'
          priority: 200
          description: 'Allow GatewayManager Azure Ports Outbound.'
        }
      }
      {
        name: 'AllowInternetAzurePortsOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: 'Internet'
          priority: 201
          description: 'Allow Internet Azure Ports Outbound.'
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

// ==================================== Route Tables ====================================

resource aksCustomRouteTable 'Microsoft.Network/routeTables@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-UD01'
  location: location
  properties: {
    routes: []
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
