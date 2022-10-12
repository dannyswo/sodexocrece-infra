param location string
param extendedLocation object
param virtualNetworkName string
param resourceGroup string
param addressSpaces array
param ipv6Enabled bool
param subnetCount int
param subnet0_name string
param subnet0_addressRange string
param subnet1_name string
param subnet1_addressRange string
param ddosProtectionPlanEnabled bool
param firewallEnabled bool
param bastionEnabled bool

resource virtualNetworkName_resource 'Microsoft.Network/VirtualNetworks@2021-01-01' = {
  name: virtualNetworkName
  location: location
  extendedLocation: (empty(extendedLocation) ? json('null') : extendedLocation)
  tags: {
    Organization: 'Sodexo'
    System: 'SodexoCrecer'
    Environment: 'SWODEV'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.169.91.0/27'
      ]
    }
    subnets: [
      {
        name: 'gateway-subnet'
        properties: {
          addressPrefix: '10.169.91.0/28'
        }
      }
      {
        name: 'applications-subnet'
        properties: {
          addressPrefix: '10.169.91.16/28'
        }
      }
    ]
    enableDdosProtection: ddosProtectionPlanEnabled
  }
  dependsOn: []
}