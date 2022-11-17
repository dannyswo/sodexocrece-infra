/**
 * Module: infraUsers
 * Depends on: N/A
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Resources ====================================

// ==================================== Users / Groups ====================================

@description('Principal ID of infrastructure user: AD User John.Doe@sodexo.com')
var infraUser1PrincipalId = '40c2e922-9fb6-4186-a53f-44439c85a9df'

// ==================================== Outputs ====================================

@description('List of Principal IDs of infrastructure users.')
output infraUsersPrincipalIds array = [
  infraUser1PrincipalId
]
