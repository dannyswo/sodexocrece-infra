/**
 * Module: appsKeyVaultRbac
 * Depends on: appsKeyVault, appsManagedIds, teamUsers
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the applications Key Vault.')
param appsKeyVaultName string

// ==================================== Resources ====================================

// ==================================== Role Assignments ====================================

// ==================================== Scope ====================================

resource appsKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: appsKeyVaultName
}

// ==================================== Security Principals ====================================

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
