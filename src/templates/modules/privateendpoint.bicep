@description('Azure region to deploy the Private Endpoint.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Standard name of the Private Endpoint.')
@minLength(4)
@maxLength(4)
param privateEndpointName string

@description('Name of the Subnet where Private Endpoint will be deployed.')
param subnetName string

@description('Private IP addresses of the Private Endpoint.')
param privateIPAddresses array

@description('ID of the service connected to the Private Endpoint.')
param serviceId string

@description('Subresource of the Private Endpoint.')
@allowed([
  'vault'
  'registry'
  'storageAccount'
  'sqlServer'
])
param groupId string

@description('Names of the VNets linked to the DNS Private Zone.')
param linkedVnetNames array

@description('Standard tags applied to all resources.')
param standardTags object = resourceGroup().tags

var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', subnetName)

var memberNamesDictionary = {
  vault: [ 'default' ]
  registry: [ 'registry', 'registry_data_eastus2' ]
  storageAccount: [ 'default' ]
  server: [ 'default' ]
}

var memberNames = memberNamesDictionary[groupId]

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${privateEndpointName}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: 'BRS-MEX-USE2-CRECESDX-${env}-${privateEndpointName}-NIC'
    ipConfigurations: [for (item, index) in memberNames: {
      name: '${privateEndpointName}-ipconfig-${memberNames[index]}'
      properties: {
        groupId: groupId
        memberName: memberNames[index]
        privateIPAddress: privateIPAddresses[index]
      }
    }]
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-connection-${groupId}'
        properties: {
          privateLinkServiceId: serviceId
          groupIds: [ groupId ]
        }
      }
    ]
  }
  tags: standardTags
}

var privateDnsZoneNamesDictionary = {
  vault: 'privatelink.vaultcore.azure.net'
  registry: 'privatelink${environment().suffixes.acrLoginServer}'
  storageAccount: 'privatelink.blob${environment().suffixes.storage}'
  sqlServer: 'privatelink${environment().suffixes.sqlServerHostname}'
}

var privateDnsZoneName = privateDnsZoneNamesDictionary[groupId]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {
  }
  tags: standardTags
}

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (item, index) in linkedVnetNames: {
  name: '${privateEndpointName}-networkLink${index}'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', item)
    }
  }
}]

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${privateEndpointName}-dnsZoneGroup'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${privateEndpointName}-dnsZoneConfig'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
