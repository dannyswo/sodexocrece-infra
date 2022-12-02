/**
 * Module: private-endpoint
 * Depends on: network
 * Used by: system/main-system
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

@description('Name suffix of the Private Endpoint.')
@minLength(4)
@maxLength(4)
param privateEndpointNameSuffix string

@description('Name of the Subnet where Private Endpoint will be deployed.')
param subnetId string

@description('Private IP addresses of the Private Endpoint.')
param privateIPAddresses array

@description('ID of the service connected (Azure resources) to the Private Endpoint.')
param serviceId string

@description('Subresource of the Private Endpoint.')
@allowed([
  'vault'
  'registry'
  'blob'
  'sqlServer'
])
param groupId string

@description('IDs of the VNets linked to the DNS Private Zone.')
param linkedVNetIds array

// ==================================== Resources ====================================

// ==================================== Private Endpoint ====================================

var memberNamesDictionary = {
  vault: [ 'default' ]
  registry: [ 'registry', 'registry_data_eastus2' ]
  blob: [ 'blob' ]
  sqlServer: [ 'sqlServer' ]
}

var memberNames = memberNamesDictionary[groupId]

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${privateEndpointNameSuffix}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: 'BRS-MEX-USE2-CRECESDX-${env}-${privateEndpointNameSuffix}-NIC'
    ipConfigurations: [for (memberName, index) in memberNames: {
      name: '${privateEndpointNameSuffix}-IPConfig-${memberNames[index]}'
      properties: {
        groupId: groupId
        memberName: memberName
        privateIPAddress: privateIPAddresses[index]
      }
    }]
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointNameSuffix}-Connection-${groupId}'
        properties: {
          privateLinkServiceId: serviceId
          groupIds: [ groupId ]
        }
      }
    ]
  }
  tags: standardTags
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${privateEndpointNameSuffix}-DnsZoneGroup'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${privateEndpointNameSuffix}-DnsZoneConfig'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
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

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (linkedVNetId, index) in linkedVNetIds: {
  name: '${groupId}-NetworkLink-${index}'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: linkedVNetId
    }
  }
}]

// ==================================== Outputs ====================================

@description('Private IP address used by the Private Endpoint NIC.')
output privateEndpointPrivateIPAddress string = privateEndpoint.properties.ipConfigurations[0].properties.privateIPAddress
