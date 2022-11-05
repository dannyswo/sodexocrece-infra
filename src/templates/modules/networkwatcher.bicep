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

@description('Name of the target Network Security Group (NSG) where flow logs will be captured.')
param targetNSGName string

@description('Name of the Storage Account where flow logs will be stored.')
param flowLogsStorageAccountName string

@description('Name of the Log Analytics Workspace used in Flow Analytics configuration.')
param flowAnalyticsWorkspaceName string

@description('Retention days of flow logs captured by the Network Watcher.')
@minValue(7)
@maxValue(180)
param flowLogsRetentionDays int

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var networkWatcherNameSuffix = 'MM02'

resource networkWatcher 'Microsoft.Network/networkWatchers@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${networkWatcherNameSuffix}'
  location: location
  properties: {
  }
  tags: standardTags
}

// resource networkWatcher 'Microsoft.Network/networkWatchers@2022-05-01' existing = {
//   name: 'NetworkWatcher_${location}'
// }

var targetNSGId = resourceId('Microsoft.Network/networkSecurityGroups', targetNSGName)

var flowLogsStorageAccountId = resourceId('Microsoft.Storage/storageAccounts', flowLogsStorageAccountName)

var flowAnalyticsWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', flowAnalyticsWorkspaceName)

resource flowLogs 'Microsoft.Network/networkWatchers/flowLogs@2022-05-01' = {
  name: '${networkWatcherNameSuffix}-flowLogs'
  parent: networkWatcher
  location: location
  properties: {
    enabled: true
    targetResourceId: targetNSGId
    storageId: flowLogsStorageAccountId
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: flowAnalyticsWorkspaceId
        workspaceRegion: location
        trafficAnalyticsInterval: 60
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

@description('Name of the created Network Watcher.')
output networkWatcherId string = networkWatcher.id

@description('ID of the created Network Watcher.')
output networkWatcherName string = networkWatcher.name
