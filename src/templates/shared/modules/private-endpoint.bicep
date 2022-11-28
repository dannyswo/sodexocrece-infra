/**
 * Module: private-endpoint
 * Depends on: network (optional)
 * Used by: shared/main-shared
 * Resources: N/A
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

@description('Standard tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@description('Standard name of the Private Endpoint.')
@minLength(4)
@maxLength(4)
param privateEndpointName string

@description('Name of the VNet where Private Endpoint will be deployed.')
param vnetName string

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
  'blob'
  'sqlServer'
])
param groupId string

@description('Names of the VNets linked to the DNS Private Zone.')
param linkedVNetNames array

// ==================================== Resources ====================================

// ==================================== Private Endpoint ====================================

var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

var memberNamesDictionary = {
  vault: [ 'default' ]
  registry: [ 'registry', 'registry_data_eastus2' ]
  blob: [ 'blob' ]
  sqlServer: [ 'sqlServer' ]
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
    ipConfigurations: [for (memberName, index) in memberNames: {
      name: '${privateEndpointName}-ipconfig-${memberNames[index]}'
      properties: {
        groupId: groupId
        memberName: memberName
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

// ==================================== Private DNS Zone ====================================

var privateDnsZoneNamesDictionary = {
  vault: 'privatelink.vaultcore.azure.net'
  registry: 'privatelink${environment().suffixes.acrLoginServer}'
  blob: 'privatelink.blob.${environment().suffixes.storage}'
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

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (linkedVNetName, index) in linkedVNetNames: {
  name: '${privateEndpointName}-NetworkLink${index}'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', linkedVNetName)
    }
  }
}]

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${privateEndpointName}-DnsZoneGroup'
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

// ==================================== Outputs ====================================

@description('Private IP address used by the Private Endpoint NIC.')
output privateEndpointPrivateIPAddress string = privateEndpoint.properties.ipConfigurations[0].properties.privateIPAddress
