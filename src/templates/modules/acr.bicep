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

@description('Suffix used in the Container Registry name.')
@minLength(6)
@maxLength(6)
param acrNameSuffix string

@description('Selected tier for the Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string

@description('If zone redundancy Enabled or Disabled for the Container Registry.')
@allowed([
  'Enabled'
  'Disabled'
])
param zoneRedundancy string

@description('Retention days of untagged images in the Container Registry.')
@minValue(7)
@maxValue(180)
param untaggedRetentionDays int

@description('Retention days of soft deleted images in the Container Registry.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionDays int

@description('Enable diagnostics to store Container Registry audit logs.')
param enableDiagnostics bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Container Registry Must be defined if enableDiagnostics is true.')
param diagnosticsWorkspaceName string

@description('Retention days of the Container Registry audit logs. Must be defined if enableDiagnostics is true.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

@description('Enable Resource Lock on Container Registry.')
param enableLock bool

@description('List of IPs or CIDRs allowed to access the Container Registry in the firewall.')
param allowedIPsOrCIDRs array = []

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

// Resource definitions

var ipRules = [for allowedIPOrCIDR in allowedIPsOrCIDRs: {
  value: allowedIPOrCIDR
  action: 'Allow'
}]

resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'azmxcr1${acrNameSuffix}'
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    zoneRedundancy: zoneRedundancy
    policies: {
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        status: 'enabled'
        days: untaggedRetentionDays
      }
      softDeletePolicy: {
        status: 'enabled'
        retentionDays: softDeleteRetentionDays
      }
      exportPolicy: {
        status: 'disabled'
      }
    }
    adminUserEnabled: false
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'None'
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: ipRules
    }
  }
  tags: standardTags
}

resource diagnosticSettings 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM08'
  scope: registry
  properties: {
    workspaceId: resourceId('Microsoft.OperationalInsights/workspaces', diagnosticsWorkspaceName)
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
    ]
  }
}

resource apsDataStorageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL08'
  scope: registry
  properties: {
    level: 'CanNotDelete'
    notes: 'Container Registry should not be deleted.'
  }
}

@description('ID of the Container Registry.')
output registryId string = registry.id

@description('URL used to log in into the Container Registry.')
output registryLoginUri string = registry.properties.loginServer
