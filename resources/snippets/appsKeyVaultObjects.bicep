/**
 * Module: appsKeyVaultObjects
 * Depends on: appsKeyVault
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

@description('Azure region.')
param location string = resourceGroup().location

// ==================================== Resource properties ====================================

@description('Name of the Key Vault.')
param keyVaultName string

// ==================================== Resources ====================================

// ==================================== Encryption Keys ====================================

// ==================================== Secrets ====================================

// ==================================== Certificates ====================================

// ==================================== Key Vault ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

// ==================================== Outputs ====================================
