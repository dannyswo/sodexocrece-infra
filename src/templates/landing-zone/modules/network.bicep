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

@description('Suffix of the Apps Shared 02 VNet name.')
@minLength(4)
@maxLength(4)
param appsShared2VNetNameSuffix string

@description('IP range or CIDR of the Apps Shared 02 VNet.')
param appsShared2VNetAddressPrefix string

@description('Suffix of the Jump Servers Subnet name.')
@minLength(4)
@maxLength(4)
param jumpServersSubnetNameSuffix string

@description('IP range or CIDR of the Jump Servers Subnet.')
param jumpServersSubnetAddressPrefix string

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

resource frontendVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
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

resource aksVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
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

resource appsShared2VNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${appsShared2VNetNameSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        appsShared2VNetAddressPrefix
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

resource frontendAksVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP01'
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

resource aksFrontendVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP03'
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

resource frontendEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP03'
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

resource endpointsFrontendVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP04'
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

resource aksEndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP05'
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

resource endpointsAksVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP06'
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

resource appsShared2AksVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP07'
  parent: appsShared2VNet
  properties: {
    remoteVirtualNetwork: {
      id: aksVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource aksAppsShared2VNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP08'
  parent: aksVNet
  properties: {
    remoteVirtualNetwork: {
      id: appsShared2VNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource appsShared2EndpointsVNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP09'
  parent: appsShared2VNet
  properties: {
    remoteVirtualNetwork: {
      id: endpointsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: false
  }
}

resource endpointsAppsShared2VNetsPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-VP10'
  parent: endpointsVNet
  properties: {
    remoteVirtualNetwork: {
      id: appsShared2VNet.id
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

resource aksNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
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
            aksSubnetAddressPrefix
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
            aksSubnetAddressPrefix
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
            aksSubnetAddressPrefix
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

// ==================================== Custom Route Tables ====================================

resource aksCustomRouteTable 'Microsoft.Network/routeTables@2022-05-01' = if (createCustomRouteTable) {
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
})
output vnets array = [
  {
    id: frontendVNet.id
    name: frontendVNet.name
  }
  {
    id: aksVNet.id
    name: aksVNet.name
  }
  {
    id: endpointsVNet.id
    name: endpointsVNet.name
  }
  {
    id: appsShared2VNet.id
    name: appsShared2VNet.name
  }
]

@description('IDs and names of the created Subnets.')
@metadata({
  id: 'ID of the Subnet.'
  name: 'Standard name of the Subnet.'
})
output subnets array = [
  {
    id: frontendVNet.properties.subnets[0].id
    name: frontendVNet.properties.subnets[0].name
  }
  {
    id: aksVNet.properties.subnets[0].id
    name: aksVNet.properties.subnets[0].name
  }
  {
    id: endpointsVNet.properties.subnets[0].id
    name: endpointsVNet.properties.subnets[0].name
  }
  {
    id: appsShared2VNet.properties.subnets[0].id
    name: appsShared2VNet.properties.subnets[0].name
  }
  {
    id: appsShared2VNet.properties.subnets[1].id
    name: appsShared2VNet.properties.subnets[1].name
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
