/**
 * Module: networkwatcher
 * Depends on: monitoringdatastorage
 * Used by: system/mainSystem
 * Common resources: RL01, MM03
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

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on Network Watcher.')
param enableLock bool

// ==================================== Resources ====================================

// ==================================== Network Watcher ====================================

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
//   scope: resourceGroup(networkWatcherRGName)
// }

// ==================================== Network Watcher Flow Logs ====================================

var targetNSGId = resourceId('Microsoft.Network/networkSecurityGroups', targetNSGName)

var flowLogsStorageAccountId = resourceId('Microsoft.Storage/storageAccounts', flowLogsStorageAccountName)

var flowAnalyticsWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', flowAnalyticsWorkspaceName)

resource flowLogs 'Microsoft.Network/networkWatchers/flowLogs@2022-05-01' = {
  name: '${networkWatcherNameSuffix}-FlowLogs'
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

// ==================================== Resource Lock ====================================

resource networkWatcherLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL03'
  scope: networkWatcher
  properties: {
    level: 'CanNotDelete'
    notes: 'Network Watcher should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('Name of the created Network Watcher.')
output networkWatcherId string = networkWatcher.id

@description('ID of the created Network Watcher.')
output networkWatcherName string = networkWatcher.name
