/**
 * Module: network-attachments
 * Depends on: network
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

// ==================================== Resources ====================================

// ==================================== Custom Route Tables ====================================

resource aksCustomRouteTable 'Microsoft.Network/routeTables@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-UD01'
  location: location
  properties: {
    routes: []
  }
  tags: standardTags
}
