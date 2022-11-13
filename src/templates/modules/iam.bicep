/**
 * Module: infraiam
 * Depends on: N/A
 * Used by: shared/main
 * Common resources: N/A
 */

// ==================================== Resources ====================================

@description('Principal ID of the system administrator: AD User danny.zamorano@softwareone.com')
var administratorPrincipalId = '40c2e922-9fb6-4186-a53f-44439c85a9df'

// ==================================== Custom Role Definitions ====================================

var azureFeatureManagerActions = [
  'Microsoft.Features/features/read'
  'Microsoft.Features/providers/features/read'
  'Microsoft.Features/providers/features/register/action'
]

var azureFeaturesManagerRoleName = 'Azure Features Manager'

resource azureFeatureManagerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(resourceGroup().id, administratorPrincipalId, azureFeaturesManagerRoleName)
  properties: {
    roleName: azureFeaturesManagerRoleName
    description: 'Read and register Azure Features and Feature Providers.'
    type: 'customRole'
    permissions: [
      {
        actions: azureFeatureManagerActions
        notActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

// ==================================== Role Assignments ====================================

var administratorRoleDefinitions = [
  {
    roleName: 'f25e0fa2-a7c8-4377-a976-54943a77a395'
    roleDescription: 'Key Vault Contributor | Lets you manage key vaults'
    roleAssignmentDescription: 'System administrator can execute management operations on Key Vault.'
  }
  {
    roleName: '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8'
    roleDescription: 'Azure Kubernetes Service Cluster Admin Role | List cluster admin credential action'
    roleAssignmentDescription: 'System administrator can obtain admin credentials on AKS Managed Cluster.'
  }
  {
    roleName: 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
    roleDescription: 'Azure Kubernetes Service RBAC Cluster Admin | Lets you manage all resources in the cluster'
    roleAssignmentDescription: 'System administrator can manage AKS Managed Cluster objects.'
  }
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data'
    roleAssignmentDescription: 'System administrator can access Storage Account Blob data.'
  }
  {
    roleName: azureFeatureManagerRoleDefinition.name
    roleDescription: 'Azure Features Manager | Read and register Azure Features and Feature Providers.'
    roleAssignmentDescription: 'System administrator can manage Azure Features.'
  }
]

resource administratorRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefinition in administratorRoleDefinitions: {
  name: guid(resourceGroup().id, administratorPrincipalId, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: administratorPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'User'
  }
}]

// ==================================== Outputs ====================================

@description('Principal ID of the system administrator.')
output administratorPrincipalId string = administratorPrincipalId
