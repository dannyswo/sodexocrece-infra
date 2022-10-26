param environment string
param location string = resourceGroup().location
param skuName string

var businessLine = 'BRS'
var businessRegion = 'LATAM'
var cloudRegion = 'USE2'
var projectName = 'CRECESDX'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}-MM01'
  location: location
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: 120
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}
