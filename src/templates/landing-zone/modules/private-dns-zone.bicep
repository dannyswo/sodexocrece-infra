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
  tags: standardTags
}
