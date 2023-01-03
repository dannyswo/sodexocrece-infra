resource gatewayNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
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

resource aksNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
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

resource endpointsNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
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
          priority: 120
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
