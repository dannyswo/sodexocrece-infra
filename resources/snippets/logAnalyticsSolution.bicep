resource logAnalyticsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: ''
  location: location
  plan: {
    publisher: 'Microsoft'
    product: 'OMSGallery/ContainerInsights'
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  tags: standardTags
}
