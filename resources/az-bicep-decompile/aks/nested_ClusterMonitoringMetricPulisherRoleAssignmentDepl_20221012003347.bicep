param reference_parameters_resourceName_addonProfiles_omsAgent_identity_objectId object

resource sodexocrecer_aks01_Microsoft_Authorization_4b4a97fd_8a06_470f_a617_31fb1a70d677 'Microsoft.ContainerService/managedClusters/providers/roleAssignments@2018-09-01-preview' = {
  name: 'sodexocrecer-aks01/Microsoft.Authorization/4b4a97fd-8a06-470f-a617-31fb1a70d677'
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb'
    principalId: reference_parameters_resourceName_addonProfiles_omsAgent_identity_objectId.addonProfiles.omsAgent.identity.objectId
    principalType: 'ServicePrincipal'
    scope: '/subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourceGroups/sodexocrecer-rg01/providers/Microsoft.ContainerService/managedClusters/sodexocrecer-aks01'
  }
}