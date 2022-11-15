/**
 * Template: shared/mainShared
 * Modules:
 * - IAM: infraUsersModule (infrausers), infraManagedIdsModule (inframanagedids), infraRgRbacModule (infrarg-rbac), infraKeyVaultRbacModule (infrakeyvault-rbac)
 * - Network: serviceEndpointPoliciesModule (serviceendpointpolicies)
 * - Security: infraKeyVaultModule (infrakeyvault), infraKeyVaultObjectsModule (infrakeyvault-objects), infraKeyVaultPoliciesModule (infrakeyvault-policies)
 * - Storage: monitoringDataStorageModule (monitoringdatastorage), monitoringDataStorageContainersModule (monitoringdatastorage-containers)
 * - Monitoring: monitoringWorkspaceModule (monitoringworkspace)
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

@description('Standard tags applied to all resources.')
@metadata({
  ApplicationName: 'ApplicationName'
  ApplicationOwner: 'ApplicationOwner'
  ApplicationSponsor: 'ApplicationSponsor'
  TechnicalContact: 'TechnicalContact'
  Maintenance: '{ ... } (maintenance standard JSON)'
  EnvironmentType: 'DEV | UAT | PRD'
  Security: '{ ... } (security standard JSON generated in Palantir)'
  DeploymentDate: 'YYY-MM-DDTHHMM UTC (autogenatered)'
  AllowShutdown: 'True (for non-prod environments), False (for prod environments)'
  dd_organization: 'MX (only for prod environments)'
  Env: 'dev | uat | prd'
  stack: 'Crececonsdx'
})
param standardTags object = resourceGroup().tags

// ==================================== Resource properties ====================================

param monitoringDataStorageNameSuffix string
param monitoringDataStorageSkuName string

param monitoringWorkspaceSkuName string
param monitoringWorkspaceCapacityReservation int
param monitoringWorkspaceLogRetentionDays int

param infraKeyVaultNameSuffix string
param infraKeyVaultEnablePurgeProtection bool
param infraKeyVaultSoftDeleteRetentionDays int
param infraKeyVaultEnableArmAccess bool
param infraKeyVaultEnableRbacAuthorization bool

param encryptionKeysIssueDateTime string
@secure()
param secrtsSqlDatabaseSqlAdminLoginName string
@secure()
param secrtsSqlDatabaseSqlAdminLoginPass string
@secure()
param secrtsVaultSqlDatabaseAADAdminLoginName string
param secrtsIssueDateTime string

param createServiceEndpointPolicies bool

// ==================================== Diagnostics options ====================================

param infraKeyVaultEnableDiagnostics bool
param infraKeyVaultLogsRetentionDays int

// ==================================== Resource Locks switches ====================================

param monitoringDataStorageEnableLock bool
param monitoringWorkspaceEnableLock bool
param infraKeyVaultEnableLock bool

// ==================================== PaaS Firewall settings ====================================

param monitoringDataStorageEnablePublicAccess bool
param monitoringDataStorageBypassAzureServices bool
param monitoringDataStorageAllowedSubnets array
param monitoringDataStorageAllowedIPsOrCIDRs array

param infraKeyVaultEnablePublicAccess bool
param infraKeyVaultBypassAzureServices bool
param infraKeyVaultAllowedSubnets array
param infraKeyVaultAllowedIPsOrCIDRs array

// ==================================== Resources ====================================

module infraUsersModule 'modules/infraUsers.bicep' = {
  name: 'infraUsersModule'
  params: {
  }
}

module infraManagedIdsModule 'modules/infraManagedIds.bicep' = {
  name: 'infraManagedIdsModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
  }
}

module infraRgRbacModule 'modules/infraRgRbac.bicep' = {
  name: 'infraRgRbacModule'
  params: {
    administratorPrincipalId: infraUsersModule.outputs.administratorPrincipalId
    aksManagedIdentityName: infraManagedIdsModule.outputs.aksManagedIdentityName
  }
}

module monitoringDataStorageModule 'modules/monitoringDataStorage.bicep' = {
  name: 'monitoringDataStorageModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    storageAccountNameSuffix: monitoringDataStorageNameSuffix
    storageAccountSkuName: monitoringDataStorageSkuName
    enableLock: monitoringDataStorageEnableLock
    enablePublicAccess: monitoringDataStorageEnablePublicAccess
    bypassAzureServices: monitoringDataStorageBypassAzureServices
    allowedSubnets: monitoringDataStorageAllowedSubnets
    allowedIPsOrCIDRs: monitoringDataStorageAllowedIPsOrCIDRs
  }
}

module monitoringDataStorageContainersModule 'modules/monitoringDataStorageContainers.bicep' = {
  name: 'monitoringDataStorageContainersModule'
  params: {
    monitoringDataStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
  }
}

module monitoringWorkspaceModule 'modules/monitoringWorkspace.bicep' = {
  name: 'monitoringWorkspaceModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    workspaceSkuName: monitoringWorkspaceSkuName
    workspaceCapacityReservation: monitoringWorkspaceCapacityReservation
    logRetentionDays: monitoringWorkspaceLogRetentionDays
    linkedStorageAccountName: monitoringDataStorageModule.outputs.storageAccountName
    enableLock: monitoringWorkspaceEnableLock
  }
}

module infraKeyVaultModule 'modules/infraKeyVault.bicep' = {
  name: 'infraKeyVaultModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    keyVaultNameSuffix: infraKeyVaultNameSuffix
    enablePurgeProtection: infraKeyVaultEnablePurgeProtection
    softDeleteRetentionDays: infraKeyVaultSoftDeleteRetentionDays
    enableArmAccess: infraKeyVaultEnableArmAccess
    enableRbacAuthorization: infraKeyVaultEnableRbacAuthorization
    enableDiagnostics: infraKeyVaultEnableDiagnostics
    diagnosticsWorkspaceName: monitoringWorkspaceModule.outputs.workspaceName
    logsRetentionDays: infraKeyVaultLogsRetentionDays
    enableLock: infraKeyVaultEnableLock
    enablePublicAccess: infraKeyVaultEnablePublicAccess
    bypassAzureServices: infraKeyVaultBypassAzureServices
    allowedSubnets: infraKeyVaultAllowedSubnets
    allowedIPsOrCIDRs: infraKeyVaultAllowedIPsOrCIDRs
  }
}

module infraKeyVaultObjectsModule 'modules/infraKeyVaultObjects.bicep' = {
  name: 'infraKeyVaultObjectsModule'
  params: {
    location: location
    keyVaultName: infraKeyVaultModule.outputs.keyVaultName
    createEncryptionKeys: true
    appsDataStorageEncryptionKeyName: 'crececonsdx-appsdatastorage-key'
    encryptionKeysIssueDateTime: encryptionKeysIssueDateTime
    createSecrets: true
    enableRandomPasswordsGeneration: false
    sqlDatabaseSqlAdminNameSecretName: 'crececonsdx-sqldatabase-sqladminloginname'
    sqlDatabaseSqlAdminNameSecretValue: secrtsSqlDatabaseSqlAdminLoginName
    sqlDatabaseSqlAdminPassSecretName: 'crececonsdx-sqldatabase-sqladminloginpass'
    sqlDatabaseSqlAdminPassSecretValue: secrtsSqlDatabaseSqlAdminLoginPass
    sqlDatabaseAADAdminNameSecretName: 'crececonsdx-sqldatabase-aadadminloginname'
    sqlDatabaseAADAdminNameSecretValue: secrtsVaultSqlDatabaseAADAdminLoginName
    secrtsIssueDateTime: secrtsIssueDateTime
  }
}

module infraKeyVaultPoliciesModule 'modules/infraKeyVaultPolicies.bicep' = {
  name: 'infraKeyVaultPoliciesModule'
  params: {
    infraKeyVaultName: infraKeyVaultModule.outputs.keyVaultName
    appGatewayPrincipalId: infraManagedIdsModule.outputs.appGatewayManagedIdentityId
    appsDataStorageAccountPrincipalId: infraManagedIdsModule.outputs.appsDataStorageManagedIdentityId
    adminsPrincipalIds: [
      infraUsersModule.outputs.administratorPrincipalId
    ]
  }
}

module serviceEndpointPoliciesModule 'modules/serviceEndpointPolicies.bicep' = if (createServiceEndpointPolicies) {
  name: 'serviceEndpointPoliciesModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    infraKeyVaultId: infraKeyVaultModule.outputs.keyVaultId
    monitoringDataStorageAccountId: monitoringDataStorageModule.outputs.storageAccountId
  }
}
