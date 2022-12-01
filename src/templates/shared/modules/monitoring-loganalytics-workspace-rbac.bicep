/**
 * Module: monitoring-loganalytics-workspace-rbac
 * Depends on: monitoring-loganalytics-workspace
 * Used by: shared/main-shared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Principal ID of the monitoring Workspace System-Assigned Managed Identity.')
param monitoringWorkspacePrincipalId string

// ==================================== Role Assignments ====================================

@description('Role Definition IDs for monitoring Workspace Managed Identity.')
var monitoringWorkspaceRoleDefinitions = [
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data.'
    roleAssignmentDescription: 'Workspace can write to monitoring Storage Account.'
  }
]

resource monitoringWorkspaceRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in monitoringWorkspaceRoleDefinitions: {
  name: guid(resourceGroup().id, monitoringWorkspacePrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: monitoringWorkspacePrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Outputs ====================================

@description('ACK of Role Assignments.')
output roleAssignmentsAck string = 'assigned'
