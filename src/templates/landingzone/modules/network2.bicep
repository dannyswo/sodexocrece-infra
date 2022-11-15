/**
 * Module: network2
 * Depends on: N/A
 * Used by: landingzone/mainLandingZone
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

@description('Standard name of the Main VNet.')
@minLength(4)
@maxLength(4)
param vnetName string

@description('IP range or CIDR of the Main VNet.')
param vnetAddressPrefix string

@description('Suffix of the Gateway Subnet name.')
@minLength(4)
@maxLength(4)
param gatewaySubnetNameSuffix string

@description('IP range or CIDR of the Gateway Subnet.')
param gatewaySubnetAddressPrefix string

@description('Suffix of the Applications Subnet name.')
@minLength(4)
@maxLength(4)
param appsSubnetNameSuffix string

@description('IP range or CIDR of the Applications Subnet.')
param appsSubnetAddressPrefix string

@description('Suffix of the Endpoints Subnet name.')
@minLength(4)
@maxLength(4)
param endpointsSubnetNameSuffix string

@description('IP range or CIDR of the Endpoints Subnet.')
param endpointsSubnetAddressPrefix string

// ==================================== Resources ====================================

// ==================================== VNets and Subnets ====================================

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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${gatewaySubnetNameSuffix}'
  parent: mainVNet
  properties: {
    addressPrefix: gatewaySubnetAddressPrefix
    networkSecurityGroup: {
      id: gatewayNSG.id
    }
  }
}

resource appsSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${appsSubnetNameSuffix}'
  properties: {
    addressPrefix: appsSubnetAddressPrefix
    networkSecurityGroup: {
      id: appsNSG.id
    }
  }
}

resource endpointsSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${endpointsSubnetNameSuffix}'
  properties: {
    addressPrefix: endpointsSubnetAddressPrefix
    networkSecurityGroup: {
      id: endpointsNSG.id
    }
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

// ==================================== Outputs ====================================

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

// ==================================== Outputs ====================================

@description('ID of the Applications VNet NSG.')
output appsNSGId string = appsNSG.id

@description('Name of the Applications VNet NSG.')
output appsNSGName string = appsNSG.name
