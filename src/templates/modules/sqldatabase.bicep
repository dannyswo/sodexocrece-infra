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

@description('Login name of the SQL Server administrator.')
@secure()
param sqlAdminLoginName string

@description('Password of the SQL Server administrator.')
@secure()
param sqlAdminLoginPass string

@description('Principal ID of the Azure AD administrator.')
param aadAdminPrincipalId string

@description('Login name of the Azure AD administrator.')
param aadAdminLoginName string

@description('SKU type for the Azure SQL Database.')
@allowed([
  'Standard'
  'GeneralPurpose'
])
param skuType string

@description('SKU size for the Azure SQL Database.')
@minValue(0)
@maxValue(4)
param skuSize int

@description('Minimum capacity of the Azure SQL Database.')
@minValue(1)
@maxValue(20)
param minCapacity int

@description('Maximum size in GB of the Azure SQL Database.')
@minValue(1)
@maxValue(2000)
param maxSizeGB int

@description('Enable zone redundancy for the Azure SQL Database.')
param zoneRedundant bool

@description('Storage redundancy used by the backups of the Azure SQL Database.')
@allowed([
  'Local'
  'Zone'
  'Geo'
])
param backupRedundancy string

@description('Enable Auditing feature on Azure SQL Server.')
param enableAuditing bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Azure SQL Database. Must be defined if enableAuditing is true.')
param diagnosticsWorkspaceName string

@description('Retention days of the Azure SQL Database audit logs. Must be defined if enableAuditing is true.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

@description('Enable Advanced Threat Protection on Azure SQL Server.')
param enableThreatProtection bool

@description('Enable Vulnerability Assessments on Azure SQL Server.')
param enableVulnerabilityAssessments bool

@description('Enable Resource Lock on Azure SQL Server.')
param enableLock bool

@description('List of IPs ranges (start and end IP addresss) allowed to access the Azure SQL Server in the firewall.')
@metadata({
  startIPAddress: 'First IP in the IP range.'
  endIPAddress: 'Last IP in the IP range.'
})
param allowedIPRanges array = []

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

// Resource definitions

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'azmxdb1${sqlServerNameSuffix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    version: '12.0'
    administratorLogin: (sqlAdminLoginName != '') ? sqlAdminLoginName : null
    administratorLoginPassword: (sqlAdminLoginPass != '') ? sqlAdminLoginPass : null
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'User'
      sid: aadAdminPrincipalId
      login: aadAdminLoginName
    }
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
  }
  tags: standardTags
}

var standardSkus = [
  {
    name: 'S0'
    tier: 'Standard'
    capacity: 10
    size: 'DTU'
  }
  {
    name: 'S1'
    tier: 'Standard'
    capacity: 20
    size: 'DTU'
  }
  {
    name: 'S2'
    tier: 'Standard'
    capacity: 50
    size: 'DTU'
  }
  {
    name: 'S3'
    tier: 'Standard'
    capacity: 100
    size: 'DTU'
  }
  {
    name: 'S4'
    tier: 'Standard'
    capacity: 200
    size: 'DTU'
  }
]

var generalPurposeSkus = [
  {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
    size: 'VCores'
  }
  {
    name: 'GP_S_Gen5_2'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
    size: 'VCores'
  }
  {
    name: 'GP_S_Gen5_4'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 4
    size: 'VCores'
  }
  {
    name: 'GP_S_Gen5_8'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 8
    size: 'VCores'
  }
  {
    name: 'GP_S_Gen5_16'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 16
    size: 'VCores'
  }
]

var selectedSku = (skuType == 'GeneralPurpose') ? generalPurposeSkus[skuSize] : standardSkus[skuSize]

var maxSizeBytes = maxSizeGB * 1000000000

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-DB01'
  parent: sqlServer
  location: location
  sku: selectedSku
  properties: {
    createMode: 'Default'
    minCapacity: minCapacity
    maxSizeBytes: maxSizeBytes
    zoneRedundant: zoneRedundant
    highAvailabilityReplicaCount: 0
    requestedBackupStorageRedundancy: backupRedundancy
    autoPauseDelay: -1
    licenseType: 'LicenseIncluded'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  tags: standardTags
}

resource connectionPolicies 'Microsoft.Sql/servers/connectionPolicies@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  properties: {
    connectionType: 'Default'
  }
}

resource firewallRules 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = [for (allowedIPRange, index) in allowedIPRanges: if (true) {
  name: 'firewallRule-${index}'
  parent: sqlServer
  properties: {
    startIpAddress: allowedIPRange.startIPAddress
    endIpAddress: allowedIPRange.endIPAddress
  }
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableAuditing) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM07'
  scope: sqlDatabase
  properties: {
    workspaceId: resourceId('Microsoft.OperationalInsights/workspaces', diagnosticsWorkspaceName)
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
      {
        category: 'DevOpsOperationsAudit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
    ]
  }
}

resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = if (enableAuditing) {
  name: 'default'
  parent: sqlServer
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource devOpsAuditingSettings 'Microsoft.Sql/servers/devOpsAuditingSettings@2022-05-01-preview' = if (enableAuditing) {
  name: 'default'
  parent: sqlServer
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource advancedThreatProtectionSettings 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2022-05-01-preview' = if (enableThreatProtection) {
  name: 'default'
  parent: sqlServer
  properties: {
    state: 'Enabled'
  }
}

resource sqlVulnerabilityAssessments 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2022-05-01-preview' = if (enableVulnerabilityAssessments) {
  name: 'default'
  parent: sqlServer
  properties: {
    state: 'Enabled'
  }
}

resource storageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL07'
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
