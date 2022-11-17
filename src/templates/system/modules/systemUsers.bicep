/**
 * Module: systemUsers
 * Depends on: N/A
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Resources ====================================

// ==================================== Users / Groups ====================================

@description('Principal ID of the team member 1: AD User John.Doe@sodexo.com')
var teamMember1PrincipalId = '40c2e922-9fb6-4186-a53f-44439c85a9df'

// ==================================== Outputs ====================================

@description('List of Principal IDs of team members.')
output teamMembersPrincipalIds array = [
  teamMember1PrincipalId
]
