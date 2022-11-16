var roleDefintions = {
  roleName: azureFeatureManagerRoleDefinition.name
  roleDescription: 'Azure Features Manager | Read and register Azure Features and Feature Providers.'
  roleAssignmentDescription: 'System administrator can manage Azure Features.'
  scope: 'Subscription'
}


var azureFeatureManagerActions = [
  'Microsoft.Features/features/read'
  'Microsoft.Features/providers/features/read'
  'Microsoft.Features/providers/features/register/action'
]

var azureFeaturesManagerRoleName = 'Azure Features Manager 2'

resource azureFeatureManagerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(tenantId, resourceGroup().id, administratorPrincipalId, azureFeaturesManagerRoleName)
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
