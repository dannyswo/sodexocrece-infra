@description('Azure region to deploy the AKS Managed Cluster.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('SKU name of the Log Analytics Workspace.')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param workspaceSkuName string

@description('Retention days of logs managed by Log Analytics Workspace.')
@minValue(7)
@maxValue(180)
param logRetentionDays int

@description('Name of the linked Storage Account for the Log Analytics Workspace.')
param linkedStorageAccountName string

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: workspaceSkuName
    }
    features: {
      immediatePurgeDataOn30Days: false
      disableLocalAuth: true
      enableDataExport: false
      enableLogAccessUsingOnlyResourcePermissions: false
    }
    forceCmkForQuery: true
    workspaceCapping: {
      dailyQuotaGb: 10
    }
    retentionInDays: logRetentionDays
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
  tags: standardTags
}

var linkedStorageAccountId = resourceId('Microsoft.Storage/storageAccounts', linkedStorageAccountName)

resource linkedStorageAccounts 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = {
  name: 'CustomLogs'
  parent: logAnalyticsWorkspace
  properties: {
    storageAccountIds: [
      linkedStorageAccountId
    ]
  }
}

@description('ID of the Log Analytics Workspace.')
output workspaceId string = logAnalyticsWorkspace.id

@description('Name of the Log Analytics Workspace.')
output workspaceName string = logAnalyticsWorkspace.name
