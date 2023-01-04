/**
 * Module: private-dns-zone
 * Depends on: network
 * Used by: landing-zone/main-landing-zone
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@description('Namespace of the Private DNS Zone.')
@allowed([
  'vault'
  'registry'
  'blob'
  'sqlServer'
  'aks'
])
param namespace string

@description('IDs of the VNets linked to the DNS Private Zone.')
param linkedVNetIds array

// ==================================== Resources ====================================

// ==================================== Private DNS Zone ====================================

var privateDnsZoneNamesDictionary = {
  vault: 'privatelink.vaultcore.azure.net'
  registry: 'privatelink${environment().suffixes.acrLoginServer}'
  blob: 'privatelink.blob.${environment().suffixes.storage}'
  sqlServer: 'privatelink${environment().suffixes.sqlServerHostname}'
  aks: 'privatelink.${location}.azmk8s.io'
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneNamesDictionary[namespace]
  location: 'global'
  properties: {
  }
  tags: union(standardTags, {
      dd_monitoring: 'Enabled'
      dd_azure_private_dns: 'Enabled'
    })
}

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (linkedVNetId, index) in linkedVNetIds: {
  name: '${namespace}-NetworkLink-${index}'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: linkedVNetId
    }
  }
}]
