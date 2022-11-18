/**
 * Module: flowLogs
 * Depends on: monitoringDataStorage, monitoringWorkspace, flowLogsAdapter
 * Used by: system/mainSystem
 * Common resources: RL01, MM02, MM03
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

@description('ID of the target Network Security Group (NSG) where flow logs will be captured.')
param flowLogsTargetNSGId string

@description('ID of the Storage Account where flow logs will be stored.')
param flowLogsStorageAccountId string

@description('Enable Network Watcher Flow Analytics feature. Must be enabled in the Subscription.')
param enableNetworkWatcherFlowAnalytics bool

@description('ID of the Log Analytics Workspace used in Flow Analytics configuration.')
param flowAnalyticsWorkspaceId string

@description('Retention days of flow logs captured by the Network Watcher.')
@minValue(7)
@maxValue(180)
param flowLogsRetentionDays int

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on Network Watcher.')
param enableLock bool

// ==================================== Resources ====================================

// ==================================== Network Watcher ====================================

resource networkWatcher 'Microsoft.Network/networkWatchers@2022-05-01' existing = {
  name: 'NetworkWatcher_${location}'
}

// resource networkWatcher 'Microsoft.Network/networkWatchers@2022-05-01' = {
//   name: 'BRS-MEX-USE2-CRECESDX-${env}-$MM02'
//   location: location
//   properties: {
//   }
//   tags: standardTags
// }

// ==================================== Network Watcher Flow Logs ====================================

resource flowLogs 'Microsoft.Network/networkWatchers/flowLogs@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM03'
  parent: networkWatcher
  location: location
  properties: {
    enabled: true
    targetResourceId: flowLogsTargetNSGId
    storageId: flowLogsStorageAccountId
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: enableNetworkWatcherFlowAnalytics
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

resource flowLogsLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL03'
  scope: flowLogs
  properties: {
    level: 'CanNotDelete'
    notes: 'Flow Logs resource should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the Flow Logs resource.')
output flowLogsId string = flowLogs.id

@description('Name of the Flow Logs resource.')
output flowLogsName string = flowLogs.name
