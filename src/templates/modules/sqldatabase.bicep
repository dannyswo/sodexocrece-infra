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

@description('Suffix used in the name of the Azure SQL Server.')
@minLength(6)
@maxLength(6)
param sqlServerNameSuffix string

@description('Login name of the administrator of the Azure SQL Server.')
@secure()
param adminLoginName string

@description('Login password of the administrator of the Azure SQL Server.')
@secure()
param adminLoginPassword string

@description('If zone redundancy is enabled for the Azure SQL Database.')
param zoneRedundant bool

@description('Storage redundancy used by the backups of the Azure SQL Database.')
@allowed([
  'Local'
  'Zone'
  'Geo'
])
param backupRedundancy string

@description('Minimum capacity of the Azure SQL Database.')
@minValue(1)
@maxValue(20)
param minCapacity int

@description('List of IPs ranges (start and end IP addresss) allowed to access the Azure SQL Server in the firewall.')
param allowedIPRanges array = []

@description('Enable auditing on Azure SQL Server.')
param enableAuditing bool

@description('URI or endpoint of the Storage Account used to store audit logs of the Azure SQL Server.')
param auditLogsStorageUri string

@description('Subscription ID of the audit logs Storage Account.')
param auditLogsStorageSubscriptionId string = subscription().subscriptionId

@description('Retention days of audit logs of Azure SQL Server.')
@minValue(7)
@maxValue(180)
param auditLogsRetentionDays int

@description('Enable vulnerability assessment on Azure SQL Server.')
param enableVulnerabilityAssessments bool

@description('List of emails of the SQL Server owners. Must be defined when enableVulnerabilityAssessments is true.')
param sqlServerOwnerEmails array = []

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'azmxdb1${sqlServerNameSuffix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    version: '12.0'
    administratorLogin: adminLoginName
    administratorLoginPassword: adminLoginPassword
    administrators: {
      azureADOnlyAuthentication: false
    }
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
  }
  tags: standardTags
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-DB01'
  parent: sqlServer
  location: location
  sku: {
    name: ''
    tier: ''
    family: ''
    capacity: ''
    size: ''
  }
  properties: {
    zoneRedundant: zoneRedundant
    minCapacity: minCapacity
    highAvailabilityReplicaCount: 0
    requestedBackupStorageRedundancy: backupRedundancy
    createMode: 'Default'

    // longTermRetentionBackupResourceId:
    // maintenanceConfigurationId:

    licenseType: licenseType
    collation: collation
    maxSizeBytes: maxSizeBytes
    autoPauseDelay: autoPauseDelay
  }
  tags: standardTags
}

resource connectionPolicies 'Microsoft.Sql/servers/connectionPolicies@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  properties: {
    connectionType: 'Redirect'
  }
}

resource firewallRules 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = [for (allowedIPRange, index) in allowedIPRanges: {
  name: 'firewallRule-${index}'
  parent: sqlServer
  properties: {
    startIpAddress: allowedIPRange.startIPAddress
    endIpAddress: allowedIPRange.endIPAddress
  }
}]

resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = if (enableAuditing) {
  name: 'default'
  parent: sqlServer
  dependsOn: [
    advancedThreatProtectionSettings
  ]
  properties: {
    state: 'Enabled'
    storageEndpoint: auditLogsStorageUri
    isAzureMonitorTargetEnabled: true
    isDevopsAuditEnabled: true
    storageAccountSubscriptionId: auditLogsStorageSubscriptionId
    auditActionsAndGroups: [
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'APPLICATION_ROLE_CHANGE_PASSWORD_GROUP'
      'BACKUP_RESTORE_GROUP'
      'USER_CHANGE_PASSWORD_GROUP'
      'DATABASE_OWNERSHIP_CHANGE_GROUP'
    ]
    queueDelayMs: 30000
    retentionDays: auditLogsRetentionDays
    isManagedIdentityInUse: true
    isStorageSecondaryKeyInUse: false
  }
}

resource advancedThreatProtectionSettings 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2022-05-01-preview' = if (enableAuditing) {
  name: 'default'
  parent: sqlServer
  properties: {
    state: 'Enabled'
  }
}

resource vulnerabilityAssessments 'Microsoft.Sql/servers/vulnerabilityAssessments@2022-05-01-preview' = if (enableVulnerabilityAssessments) {
  name: 'default'
  parent: sqlServer
  properties: {
    recurringScans: {
      isEnabled: true
      emails: sqlServerOwnerEmails
      emailSubscriptionAdmins: false
    }
    storageContainerSasKey: ''
    storageContainerPath: ''
  }
}

resource storageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AL04'
  scope: sqlServer
  properties: {
    level: 'CanNotDelete'
    notes: 'Azure SQL Server should not be deleted.'
  }
}

@description('ID of the Azure SQL Server')
output sqlServerId string = sqlServer.id

@description('ID of the Azure SQL Database')
output sqlDatabaseId string = sqlDatabase.id
