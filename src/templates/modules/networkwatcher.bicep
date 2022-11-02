@description('Azure region to deploy the AKS Managed Cluster.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param environment string

@description('ID of the target Network Security Group (NSG) where flow logs will be captured.')
param targetNSGId string

@description('ID of the target Storage Account where flow logs will be stored.')
param targetStorageAccountId string

@description('ID of the target Log Analytics Workspace where flow logs will be analyzed.')
param targetWorkspaceId string

@description('Retention days of flow logs captured by the Network Watcher.')
@minValue(7)
@maxValue(180)
param flowLogsRetentionDays int

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

resource networkWatcher 'Microsoft.Network/networkWatchers@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-NW01'
  location: location
  properties: {
  }
  tags: standardTags
}

resource flowLogs 'Microsoft.Network/networkWatchers/flowLogs@2022-05-01' = {
  name: 'NW01-flowLogs'
  parent: networkWatcher
  location: location
  properties: {
    enabled: true
    targetResourceId: targetNSGId
    storageId: targetStorageAccountId
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: targetWorkspaceId
        workspaceRegion: location
      }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      enabled: true
      days: flowLogsRetentionDays
    }
  }
  tags: standardTags
}
