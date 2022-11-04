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
  'PerGB2018'
  'CapacityReservation'
])
param workspaceSkuName string

@description('Capacity reservation in GBs for the Log Analytics Workspace.')
@allowed([
  0
  100
  200
  500
  1000
])
param workspaceCapacityReservation int

@description('Retention days of logs managed by Log Analytics Workspace.')
@minValue(30)
@maxValue(730)
param logRetentionDays int

@description('Name of the linked Storage Account for the Log Analytics Workspace.')
param linkedStorageAccountName string

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var workspaceSku = (workspaceSkuName == 'CapacityReservation') ? {
  name: workspaceSkuName
  capacityReservationLevel: workspaceCapacityReservation
} : {
  name: workspaceSkuName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: workspaceSku
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
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
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
