/**
 * Module: network
 * Depends on: N/A
 * Used by: landing-zone/main-landing-zone
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

@description('Suffix of the Frontend VNet name.')
@minLength(4)
@maxLength(4)
param frontendVNetNameSuffix string

@description('IP range or CIDR of the Frontend VNet.')
param frontendVNetAddressPrefix string

@description('Suffix of the Gateway Subnet name.')
@minLength(4)
@maxLength(4)
param gatewaySubnetNameSuffix string

@description('IP range or CIDR of the Gateway Subnet.')
param gatewaySubnetAddressPrefix string

@description('Suffix of the Applications VNet name.')
@minLength(4)
@maxLength(4)
param aksVNetNameSuffix string

@description('IP range or CIDR of the Applications VNet.')
param aksVNetAddressPrefix string

@description('Suffix of the Applications Subnet name.')
@minLength(4)
@maxLength(4)
param aksSubnetNameSuffix string

@description('IP range or CIDR of the Applications Subnet.')
param aksSubnetAddressPrefix string

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

@description('Suffix of the Jump Servers VNet name.')
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

@description('Create custom Route Table for AKS attached to Gateway and Apps VNet.')
param createCustomRouteTable bool

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

var aksSubnetServiceEndpoints0 = (enableKeyVaultServiceEndpoint) ? [ serviceEndpointDefinitions.keyVault ] : []
var aksSubnetServiceEndpoints1 = (enableStorageAccountServiceEndpoint) ? concat(aksSubnetServiceEndpoints0, [ serviceEndpointDefinitions.storageAccount ]) : aksSubnetServiceEndpoints0
var aksSubnetServiceEndpoints2 = (enableSqlDatabaseServiceEndpoint) ? concat(aksSubnetServiceEndpoints1, [ serviceEndpointDefinitions.sql ]) : aksSubnetServiceEndpoints1
var aksSubnetServiceEndpoints = (enableContainerRegistryServiceEndpoint) ? concat(aksSubnetServiceEndpoints2, [ serviceEndpointDefinitions.containerRegistry ]) : aksSubnetServiceEndpoints2

var jumpServersSubnetServiceEndpoints0 = (enableKeyVaultServiceEndpoint) ? [ serviceEndpointDefinitions.keyVault ] : []
var jumpServersSubnetServiceEndpoints1 = (enableStorageAccountServiceEndpoint) ? concat(jumpServersSubnetServiceEndpoints0, [ serviceEndpointDefinitions.storageAccount ]) : jumpServersSubnetServiceEndpoints0
var jumpServersSubnetServiceEndpoints2 = (enableSqlDatabaseServiceEndpoint) ? concat(jumpServersSubnetServiceEndpoints1, [ serviceEndpointDefinitions.sql ]) : jumpServersSubnetServiceEndpoints1
var jumpServersSubnetServiceEndpoints = (enableContainerRegistryServiceEndpoint) ? concat(jumpServersSubnetServiceEndpoints2, [ serviceEndpointDefinitions.containerRegistry ]) : jumpServersSubnetServiceEndpoints2

var devopsAgentsSubnetServiceEndpoints0 = (enableKeyVaultServiceEndpoint) ? [ serviceEndpointDefinitions.keyVault ] : []
var devopsAgentsSubnetServiceEndpoints1 = (enableStorageAccountServiceEndpoint) ? concat(devopsAgentsSubnetServiceEndpoints0, [ serviceEndpointDefinitions.storageAccount ]) : devopsAgentsSubnetServiceEndpoints0
var devopsAgentsSubnetServiceEndpoints2 = (enableSqlDatabaseServiceEndpoint) ? concat(devopsAgentsSubnetServiceEndpoints1, [ serviceEndpointDefinitions.sql ]) : devopsAgentsSubnetServiceEndpoints1
var devopsAgentsSubnetServiceEndpoints = (enableContainerRegistryServiceEndpoint) ? concat(devopsAgentsSubnetServiceEndpoints2, [ serviceEndpointDefinitions.containerRegistry ]) : devopsAgentsSubnetServiceEndpoints2

resource frontendVNet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${frontendVNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        frontendVNetAddressPrefix
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
          routeTable: (createCustomRouteTable) ? {
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

resource aksVNet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        aksVNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'BRS-MEX-USE2-CRECESDX-${env}-${aksSubnetNameSuffix}'
        properties: {
          addressPrefix: aksSubnetAddressPrefix
          networkSecurityGroup: {
            id: aksNSG.id
          }
          routeTable: (createCustomRouteTable) ? {
            id: aksCustomRouteTable.id
          } : null
          serviceEndpoints: aksSubnetServiceEndpoints
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource endpointsVNet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
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

resource jumpServersVNet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
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
          serviceEndpoints: jumpServersSubnetServiceEndpoints
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

resource devopsAgentsVNet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
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
          serviceEndpoints: devopsAgentsSubnetServiceEndpoints
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
  tags: standardTags
}

// ==================================== VNets Peerings ====================================

resource frontendAksVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${frontendVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}'
  parent: frontendVNet
  properties: {
    remoteVirtualNetwork: {
      id: aksVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource aksFrontendVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${frontendVNetNameSuffix}'
  parent: aksVNet
  properties: {
    remoteVirtualNetwork: {
      id: frontendVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource frontendEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${frontendVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}'
  parent: frontendVNet
  properties: {
    remoteVirtualNetwork: {
      id: endpointsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource endpointsFrontendVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${frontendVNetNameSuffix}'
  parent: endpointsVNet
  properties: {
    remoteVirtualNetwork: {
      id: frontendVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource aksEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}'
  parent: aksVNet
  properties: {
    remoteVirtualNetwork: {
      id: endpointsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource endpointsAksVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}'
  parent: endpointsVNet
  properties: {
    remoteVirtualNetwork: {
      id: aksVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource jumpServersAksVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}'
  parent: jumpServersVNet
  properties: {
    remoteVirtualNetwork: {
      id: aksVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource aksJumpServersVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetNameSuffix}'
  parent: aksVNet
  properties: {
    remoteVirtualNetwork: {
      id: jumpServersVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource jumpServersEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}'
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

resource endpointsJumpServersVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetNameSuffix}'
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

resource jumpServersFrontendVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${frontendVNetNameSuffix}'
  parent: jumpServersVNet
  properties: {
    remoteVirtualNetwork: {
      id: frontendVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource frontendJumpServersVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${frontendVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${jumpServersVNetNameSuffix}'
  parent: frontendVNet
  properties: {
    remoteVirtualNetwork: {
      id: jumpServersVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource devopsAgentsAksVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}'
  parent: devopsAgentsVNet
  properties: {
    remoteVirtualNetwork: {
      id: aksVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource aksDevopsAgentsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${aksVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsVNetNameSuffix}'
  parent: aksVNet
  properties: {
    remoteVirtualNetwork: {
      id: devopsAgentsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource devopsAgentsEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}'
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

resource endpointsDevopsAgentsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsVNetNameSuffix}_BRS-MEX-USE2-CRECESDX-${env}-${devopsAgentsVNetNameSuffix}'
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

resource gatewayNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS01'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: '*'
          priority: 100
          description: 'Allow GatewayManager Azure Ports Inbound.'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow GatewayManager Azure Ports Inbound.'
        }
      }
      {
        name: 'AllowVNetsHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRanges: [
            '80'
            '443'
          ]
          destinationAddressPrefix: '*'
          priority: 120
          description: 'Allow Jump Servers Subnets HTTP Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource aksNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS02'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowVNetsHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            gatewaySubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRanges: [
            '80'
            '443'
          ]
          destinationAddressPrefix: '*'
          priority: 100
          description: 'Allow Gateway and Jump Servers Subnets HTTP Inbound.'
        }
      }
      {
        name: 'DenyInternetAllInbound'
        properties: {
          access: 'Deny'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          priority: 4096
          description: 'Deny Internet All Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource endpointsNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS03'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowVNetsHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            aksSubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRanges: [
            '80'
            '443'
          ]
          destinationAddressPrefix: '*'
          priority: 100
          description: 'Allow AKS and Jump Servers Subnets HTTP Inbound.'
        }
      }
      {
        name: 'AllowVNetsSqlServerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: [
            aksSubnetAddressPrefix
            jumpServersSubnetAddressPrefix
          ]
          destinationPortRange: '1433'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow AKS and Jump Servers Subnets SQL Server Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource jumpServersNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
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
          priority: 100
          description: 'Allow Internet RDP Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource devopsAgentsNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS05'
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyInternetAllInbound'
        properties: {
          access: 'Deny'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          priority: 4096
          description: 'Deny Internet All Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

// ==================================== Custom Route Tables ====================================

resource aksCustomRouteTable 'Microsoft.Network/routeTables@2022-07-01' = if (createCustomRouteTable) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-UD01'
  location: location
  properties: {
    routes: []
  }
  tags: standardTags
}

// ==================================== Outputs ====================================

@description('IDs, names and CIDRs of the created VNets.')
@metadata({
  id: 'ID of the VNet.'
  name: 'Standard name of the VNet.'
  addressPrefix: 'CIDR of the VNet.'
})
output vnets array = [
  {
    id: frontendVNet.id
    name: frontendVNet.name
    addressPrefix: frontendVNet.properties.addressSpace.addressPrefixes[0]
  }
  {
    id: aksVNet.id
    name: aksVNet.name
    addressPrefix: aksVNet.properties.addressSpace.addressPrefixes[0]
  }
  {
    id: endpointsVNet.id
    name: endpointsVNet.name
    addressPrefix: endpointsVNet.properties.addressSpace.addressPrefixes[0]
  }
  {
    id: jumpServersVNet.id
    name: jumpServersVNet.name
    addressPrefix: jumpServersVNet.properties.addressSpace.addressPrefixes[0]
  }
  {
    id: devopsAgentsVNet.id
    name: devopsAgentsVNet.name
    addressPrefix: devopsAgentsVNet.properties.addressSpace.addressPrefixes[0]
  }
]

@description('IDs, names and CIDRs of the created Subnets.')
@metadata({
  id: 'ID of the Subnet.'
  name: 'Standard name of the Subnet.'
  addressPrefix: 'CIDR of the Subnet.'
})
output subnets array = [
  {
    id: frontendVNet.properties.subnets[0].id
    name: frontendVNet.properties.subnets[0].name
    addressPrefix: frontendVNet.properties.subnets[0].properties.addressPrefix
  }
  {
    id: aksVNet.properties.subnets[0].id
    name: aksVNet.properties.subnets[0].name
    addressPrefix: aksVNet.properties.subnets[0].properties.addressPrefix
  }
  {
    id: endpointsVNet.properties.subnets[0].id
    name: endpointsVNet.properties.subnets[0].name
    addressPrefix: endpointsVNet.properties.subnets[0].properties.addressPrefix
  }
  {
    id: jumpServersVNet.properties.subnets[0].id
    name: jumpServersVNet.properties.subnets[0].name
    addressPrefix: jumpServersVNet.properties.subnets[0].properties.addressPrefix
  }
  {
    id: devopsAgentsVNet.properties.subnets[0].id
    name: devopsAgentsVNet.properties.subnets[0].name
    addressPrefix: devopsAgentsVNet.properties.subnets[0].properties.addressPrefix
  }
]

@description('List of IDs and names of the created NSGs.')
@metadata({
  id: 'ID of the NSG.'
  name: 'Standard name of the NSG.'
})
output networkSecurityGroups array = [
  {
    id: gatewayNSG.id
    name: gatewayNSG.name
  }
  {
    id: aksNSG.id
    name: aksNSG.name
  }
  {
    id: endpointsNSG.id
    name: endpointsNSG.name
  }
  {
    id: jumpServersNSG.id
    name: jumpServersNSG.name
  }
  {
    id: devopsAgentsNSG.id
    name: devopsAgentsNSG.name
  }
]
