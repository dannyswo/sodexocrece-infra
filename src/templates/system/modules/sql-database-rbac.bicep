/**
 * Module: sql-database-rbac
 * Depends on: sql-database
 * Used by: system/main-system
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the Azure SQL Server System-Assigned Managed Identity.')
param sqlServerPrincipalId string

// ==================================== Role Assignments ====================================

@description('Role Definition IDs for Azure SQL to monitoring Storage Account communication.')
var sqlDatabaseRoleDefinitions = [
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data.'
    roleAssignmentDescription: 'Azure SQL Server can write to monitoring Storage Account.'
  }
]

resource sqlDatabaseRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in sqlDatabaseRoleDefinitions: {
  name: guid(resourceGroup().id, sqlServerPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: sqlServerPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
