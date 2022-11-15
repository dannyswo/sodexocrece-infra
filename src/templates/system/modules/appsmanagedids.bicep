/**
 * Module: appsManagedIds
 * Depends on: N/A
 * Used by: system/mainSystem
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

@description('Standard tags applied to all resources.')
param standardTags object

// ==================================== Resources ====================================

// ==================================== User-Assigned Managed Identities ====================================

// ==================================== Outputs ====================================
