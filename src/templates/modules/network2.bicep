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

@description('Standard name of the Main VNet.')
@minLength(4)
@maxLength(4)
param vnetName string

@description('IP range or CIDR of the Main VNet.')
param vnetAddressPrefix string

@description('Standard name of the Gateway Subnet.')
@minLength(4)
@maxLength(4)
param gatewaySubnetName string

@description('IP range or CIDR of the Gateway Subnet.')
param gatewaySubnetAddressPrefix string

@description('Standard name of the Applications Subnet.')
@minLength(4)
@maxLength(4)
param appsSubnetName string

@description('IP range or CIDR of the Applications Subnet.')
param appsSubnetAddressPrefix string

@description('Standard name of the Endpoints Subnet.')
@minLength(4)
@maxLength(4)
param endpointsSubnetName string

@description('IP range or CIDR of the Endpoints Subnet.')
param endpointsSubnetAddressPrefix string

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

resource mainVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${vnetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${gatewaySubnetName}'
  parent: mainVNet
  properties: {
    addressPrefix: gatewaySubnetAddressPrefix
    networkSecurityGroup: {
      id: gatewayNSG.id
    }
  }
}

resource appsSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${appsSubnetName}'
  properties: {
    addressPrefix: appsSubnetAddressPrefix
    networkSecurityGroup: {
      id: appsNSG.id
    }
  }
}

resource endpointsSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsSubnetName}'
  properties: {
    addressPrefix: endpointsSubnetAddressPrefix
    networkSecurityGroup: {
      id: endpointsNSG.id
    }
  }
}

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
        name: 'AllowGatewayHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: gatewaySubnetAddressPrefix
          destinationPortRange: '80'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow Gateway HTTP Inbound.'
        }
      }
      {
        name: 'AllowGatewayHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: gatewaySubnetAddressPrefix
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          priority: 111
          description: 'Allow Gateway HTTPS Inbound.'
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
        name: 'AllowApplicationsHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: appsSubnetAddressPrefix
          destinationPortRange: '80'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow Applications HTTP Inbound.'
        }
      }
      {
        name: 'AllowApplicationsHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: appsSubnetAddressPrefix
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          priority: 111
          description: 'Allow Applications HTTPS Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

@description('ID of the created VNet.')
output vnetId string = mainVNet.id

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
    id: gatewaySubnet.id
    name: gatewaySubnet.name
  }
  {
    id: appsSubnet.id
    name: appsSubnet.name
  }
  {
    id: endpointsSubnet.id
    name: endpointsSubnet.name
  }
]

@description('ID of the Applications VNet NSG.')
output appsNSGId string = appsNSG.id

@description('Name of the Applications VNet NSG.')
output appsNSGName string = appsNSG.name
