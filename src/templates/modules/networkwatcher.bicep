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

@description('Name of the target Network Security Group (NSG) where flow logs will be captured.')
param targetNsgName string

@description('Name of the target Log Analytics Workspace where flow logs will be analyzed.')
param targetWorkspaceName string

@description('Retention days of flow logs captured by the Network Watcher.')
@minValue(7)
@maxValue(180)
param flowLogsRetentionDays int

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var networkWatcherNameSuffix = 'NW01'

resource networkWatcher 'Microsoft.Network/networkWatchers@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${networkWatcherNameSuffix}'
  location: location
  properties: {
  }
  tags: standardTags
}

var targetNSGId = resourceId('Microsoft.Network/networkSecurityGroups', targetNsgName)
var targetWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', targetWorkspaceName)

resource flowLogs 'Microsoft.Network/networkWatchers/flowLogs@2022-05-01' = {
  name: '${networkWatcherNameSuffix}-flowLogs'
  parent: networkWatcher
  location: location
  properties: {
    enabled: true
    targetResourceId: targetNSGId
    storageId: flowLogsStorageAccount.id
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

resource flowLogsStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-ST02'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    immutableStorageWithVersioning: {
      enabled: false
    }
    isHnsEnabled: true
    isNfsV3Enabled: false
    isSftpEnabled: false
    largeFileSharesState: 'Disabled'
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: false
    isLocalUserEnabled: false
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    minimumTlsVersion: '1.2'
  }
  tags: standardTags
}
