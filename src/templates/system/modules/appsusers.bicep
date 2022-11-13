/**
 * Module: infraiam
 * Depends on: N/A
 * Used by: shared/main
 * Common resources: N/A
 */

// ==================================== Resources ====================================

// ==================================== Users / Groups ====================================

@description('Principal ID of the system administrator: AD User danny.zamorano@softwareone.com')
var administratorPrincipalId = '40c2e922-9fb6-4186-a53f-44439c85a9df'

// ==================================== Outputs ====================================

@description('Principal ID of the system administrator.')
output administratorPrincipalId string = administratorPrincipalId
