/**
 * Module: sqlDatabase
 * Depends on: monitoringWorkspace
 * Used by: system/mainSystem
 * Common resources: RL07, MM07
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

@description('Register Azure AD administrator for SQL Server.')
param enableAADAdminUser bool

@description('ID of the AAD Tenant where admin user is registered.')
param tenantId string = subscription().tenantId

@description('Login name of the Azure AD administrator for SQL Server.')
param aadAdminLoginName string

@description('Principal ID of the Azure AD administrator for SQL Server.')
param aadAdminPrincipalId string

@description('SKU type for the Azure SQL Database. Use GeneralPurpose for zone redudant database.')
@allowed([
  'Standard'
  'GeneralPurpose'
])
param sqlDatabaseSkuType string

@description('SKU size for the Azure SQL Database.')
@minValue(0)
@maxValue(4)
param sqlDatabaseSkuSize int

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

@description('Number of replicas for the Azure SQL Database.')
param replicaCount int

@description('Route read-only connections to secondary read-only replicas.')
@allowed([
  'Enabled'
  'Disabled'
])
param readScaleOut string

@description('Storage redundancy used by the backups of the Azure SQL Database.')
@allowed([
  'Local'
  'Zone'
  'Geo'
])
param backupRedundancy string

@description('Type of license for Azure SQL Database instance.')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string

@description('Collation of the Azure SQL Database instance.')
param collation string

// ==================================== Diagnostics options ====================================

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

@description('Enable storageless Vulnerability Assessments on Azure SQL Server.')
param enableStoragelessVunerabilityAssessments bool

@description('URI of the monitoring data Storage Account Blob Service. Required if storageless VA is enabled.')
param monitoringDataStorageBlobServiceUri string

@description('List of destination emails of vulnerability assessments reports.')
param vulnerabilityAssessmentsEmails array

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on Azure SQL Server.')
param enableLock bool

// ==================================== PaaS Firewall settings ====================================

@description('Enable public access in the PaaS firewall.')
param enablePublicAccess bool

@description('List of Subnets allowed to access the Azure SQL Database in the firewall.')
@metadata({
  vnetName: 'Name of VNet.'
  subnetName: 'Name of the Subnet.'
})
param allowedSubnets array

@description('List of IPs ranges (start and end IP addresss) allowed to access the Azure SQL Server in the firewall.')
@metadata({
  startIPAddress: 'First IP in the IP range.'
  endIPAddress: 'Last IP in the IP range.'
})
param allowedIPRanges array

// ==================================== Resources ====================================

// ==================================== SQL Server ====================================

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
    administrators: (enableAADAdminUser) ? {
      administratorType: 'ActiveDirectory'
      principalType: 'User'
      login: (aadAdminLoginName != '') ? aadAdminLoginName : null
      sid: (aadAdminPrincipalId != '') ? aadAdminPrincipalId : null
      tenantId: tenantId
      azureADOnlyAuthentication: false
    } : null
    publicNetworkAccess: (enablePublicAccess) ? 'Enabled' : 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
  }
  tags: standardTags
}

// ==================================== SQL Database ====================================

var selectedSku = (sqlDatabaseSkuType == 'GeneralPurpose') ? generalPurposeSkus[sqlDatabaseSkuSize] : standardSkus[sqlDatabaseSkuSize]

var selectedSkuLimits = (sqlDatabaseSkuType == 'GeneralPurpose') ? generalPurposeSkuLimits[sqlDatabaseSkuSize] : standardSkuLimits[sqlDatabaseSkuSize]

var maxSizeBytes = maxSizeGB * 1073741824 // 1024 * 1024 * 1024 B

var validMaxSizeBytes = (maxSizeBytes <= selectedSkuLimits.storageMaxSizeGB) ? maxSizeBytes : selectedSkuLimits.storageMaxSizeGB

var isZoneRedundant = (sqlDatabaseSkuType == 'GeneralPurpose') ? zoneRedundant : false

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-DB01'
  parent: sqlServer
  location: location
  sku: selectedSku
  properties: {
    createMode: 'Default'
    minCapacity: minCapacity
    maxSizeBytes: validMaxSizeBytes
    zoneRedundant: isZoneRedundant
    highAvailabilityReplicaCount: replicaCount
    readScale: readScaleOut
    requestedBackupStorageRedundancy: backupRedundancy
    licenseType: licenseType
    collation: collation
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

// ==================================== Azure SQL Server SKUs ====================================

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

// ==================================== Azure SQL Server SKU Limits ====================================

var standardSkuLimits = [
  {
    storageMaxSizeGB: 250 * 1073741824 // 250 GB
  }
  {
    storageMaxSizeGB: 250 * 1073741824 // 250 GB
  }
  {
    storageMaxSizeGB: 250 * 1073741824 // 250 GB
  }
  {
    storageMaxSizeGB: 1024 * 1073741824 // 1024 GB
  }
  {
    storageMaxSizeGB: 1024 * 1073741824 // 1024 GB
  }
]

var generalPurposeSkuLimits = [
  {
    storageMaxSizeGB: 512 * 1073741824 // 512 GB
  }
  {
    storageMaxSizeGB: 1024 * 1073741824 // 1024 GB
  }
  {
    storageMaxSizeGB: 1024 * 1073741824 // 1024 GB
  }
  {
    storageMaxSizeGB: 2048 * 1073741824 // 2048 GB
  }
  {
    storageMaxSizeGB: 3072 * 1073741824 // 3072 GB
  }
]

// ==================================== PaaS Firewall ====================================

resource virtualNetworkRules 'Microsoft.Sql/servers/virtualNetworkRules@2022-05-01-preview' = [for (allowedSubnet, index) in allowedSubnets: if (enablePublicAccess) {
  name: 'virtualNetworkRules-${index}'
  parent: sqlServer
  properties: {
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', allowedSubnet.vnetName, allowedSubnet.subnetName)
    ignoreMissingVnetServiceEndpoint: false
  }
}]

resource firewallRules 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = [for (allowedIPRange, index) in allowedIPRanges: if (enablePublicAccess) {
  name: 'firewallRules-${index}'
  parent: sqlServer
  properties: {
    startIpAddress: allowedIPRange.startIPAddress
    endIpAddress: allowedIPRange.endIPAddress
  }
}]

// ==================================== Diagnostics: Auditing ====================================

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableAuditing) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM07'
  scope: sqlDatabase
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
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

resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  properties: {
    state: (enableAuditing) ? 'Enabled' : 'Disabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource devOpsAuditingSettings 'Microsoft.Sql/servers/devOpsAuditingSettings@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  properties: {
    state: (enableAuditing) ? 'Enabled' : 'Disabled'
    isAzureMonitorTargetEnabled: true
  }
}

// ==================================== Diagnostics: Vulnerability Assessments and Advanced Threat Protection ====================================

resource advancedThreatProtectionSettings 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  properties: {
    state: (enableThreatProtection) ? 'Enabled' : 'Disabled'
  }
}

resource sqlVulnerabilityAssessments 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  dependsOn: [
    advancedThreatProtectionSettings
  ]
  properties: {
    state: (enableStoragelessVunerabilityAssessments) ? ((enableVulnerabilityAssessments) ? 'Enabled' : 'Disabled') : 'Disabled'
  }
}

resource vulnerabilityAssessments 'Microsoft.Sql/servers/vulnerabilityAssessments@2022-05-01-preview' = {
  name: 'default'
  parent: sqlServer
  dependsOn: [
    advancedThreatProtectionSettings
  ]
  properties: {
    storageContainerPath: '${monitoringDataStorageBlobServiceUri}vulnerability-assessment'
    recurringScans: {
      isEnabled: (!enableStoragelessVunerabilityAssessments) ? enableVulnerabilityAssessments : false
      emails: vulnerabilityAssessmentsEmails
      emailSubscriptionAdmins: false
    }
  }
}

// ==================================== Role Assignments ====================================

@description('Role Definition IDs for Azure SQL to monitoring data Storage Account communication.')
var sqlDatabaseRoleDefinitions = [
  {
    roleName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    roleDescription: 'Storage Blob Data Contributor | Allows for read, write and delete access to Azure Storage blob containers and data.'
    roleAssignmentDescription: 'Azure SQL Server can write to monitoring data Storage Account.'
  }
]

resource sqlDatabaseRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in sqlDatabaseRoleDefinitions: {
  name: guid(resourceGroup().id, sqlServer.id, roleDefinition.roleName)
  scope: resourceGroup()
  properties: {
    description: roleDefinition.roleAssignmentDescription
    principalId: sqlServer.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.roleName)
    principalType: 'ServicePrincipal'
  }
}]

// ==================================== Resource Lock ====================================

resource storageAccountLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL07'
  scope: sqlServer
  properties: {
    level: 'CanNotDelete'
    notes: 'Azure SQL Server should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the Azure SQL Server instance.')
output sqlServerId string = sqlServer.id

@description('ID of the Azure SQL Database.')
output sqlDatabaseId string = sqlDatabase.id
