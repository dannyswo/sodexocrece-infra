/**
 * Module: monitoring-loganalytics-workspace
 * Depends on: monitoring-storage-account
 * Used by: shared/main-shared
 * Common resources: RL02
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@description('SKU name of the monitoring Workspace.')
@allowed([
  'PerGB2018'
  'CapacityReservation'
])
param workspaceSkuName string

@description('Capacity reservation in GBs for the monitoring Workspace.')
@allowed([
  0
  100
  200
  500
  1000
])
param workspaceCapacityReservation int

@description('Retention days of logs managed by monitoring Workspace.')
@minValue(7)
@maxValue(730)
param logRetentionDays int

@description('Name of the linked Storage Account for the monitoring Workspace.')
param linkedStorageAccountName string

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on monitoring Workspace.')
param enableLock bool

// ==================================== Resources ====================================

// ==================================== Log Analytics Workspace ====================================

var workspaceSku = (workspaceSkuName == 'CapacityReservation') ? {
  name: workspaceSkuName
  capacityReservationLevel: workspaceCapacityReservation
} : {
  name: workspaceSkuName
}

resource monitoringWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: workspaceSku
    features: {
      immediatePurgeDataOn30Days: false
      disableLocalAuth: false
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
  tags: union(standardTags, {
      dd_monitoring: 'Enabled'
      dd_azure_insightsworkspace: 'Enabled'
    })
}

// ==================================== Workspace Linked Storage Accounts ====================================

var linkedStorageAccountId = resourceId('Microsoft.Storage/storageAccounts', linkedStorageAccountName)

resource linkedStorageAccountsCustomLogs 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = {
  name: 'CustomLogs'
  parent: monitoringWorkspace
  properties: {
    storageAccountIds: [
      linkedStorageAccountId
    ]
  }
}

resource linkedStorageAccountsQuery 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = {
  name: 'Query'
  parent: monitoringWorkspace
  properties: {
    storageAccountIds: [
      linkedStorageAccountId
    ]
  }
}

resource linkedStorageAccountsAlerts 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = {
  name: 'Alerts'
  parent: monitoringWorkspace
  properties: {
    storageAccountIds: [
      linkedStorageAccountId
    ]
  }
}

// ==================================== Workspace Solutions ====================================

resource sqlAuditingSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SQLAuditing[${monitoringWorkspace.name}]'
  location: location
  plan: {
    name: 'SQLAuditing[${monitoringWorkspace.name}]'
    product: 'SQLAuditing'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: monitoringWorkspace.id
  }
}

// ==================================== Resource Lock ====================================

resource logAnalyticsWorkspaceLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL02'
  scope: monitoringWorkspace
  properties: {
    level: 'CanNotDelete'
    notes: 'Workspace for monitoring should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the monitoring Workspace.')
output workspaceId string = monitoringWorkspace.id

@description('Name of the monitoring Workspace.')
output workspaceName string = monitoringWorkspace.name

@description('Principal ID of the monitoring Workspace System-Assigned Managed Identity.')
output workspacePrincipalId string = monitoringWorkspace.identity.principalId
