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

@description('Standard tags applied to all resources.')
@metadata({
  ApplicationName: ''
  ApplicationOwner: ''
  ApplicationSponsor: ''
  TechnicalContact: ''
  Billing: ''
  Maintenance: ''
  EnvironmentType: ''
  Security: ''
  DeploymentDate: ''
  dd_organization: ''
})
param standardTags object = resourceGroup().tags

param monitoringDataStorageNameSuffix string
param monitoringDataStorageSkuName string

param workspaceSkuName string
param workspaceLogRetentionDays int

param flowLogsRetentionDays int

module monitoringDataStorageModule '../modules/monitoringdatastorage.bicep' = {
  name: 'monitoringDataStorageModule'
  params: {
    location: location
    env: env
    storageAccountNameSuffix: monitoringDataStorageNameSuffix
    storageAccountSkuName: monitoringDataStorageSkuName
    standardTags: standardTags
  }
}

module logAnalyticsModule '../modules/loganalytics.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    location: location
    env: env
    workspaceSkuName: workspaceSkuName
    logRetentionDays: workspaceLogRetentionDays
    linkedStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
    standardTags: standardTags
  }
}

module networkWatcherModule '../modules/networkwatcher.bicep' = {
  name: 'networkWatcherModule'
  params: {
    location: location
    env: env
    targetNsgName: networkModule.outputs.appsNSGName
    flowLogsStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
    flowAnalyticsWorkspaceName: logAnalyticsModule.outputs.workspaceName
    flowLogsRetentionDays: flowLogsRetentionDays
    standardTags: standardTags
  }
}
