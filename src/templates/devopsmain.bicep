/**
 * Template: shared/main
 * Modules:
 * - IAM: infraManagedIdsModule (inframanagedids), infraIamModule (infraiam)
 * - Security: infraKeyVaultModule (infrakeyvault), infraKeyVaultObjectsModule (infrakeyvaultobjects), infraKeyVaultPoliciesModule (infrakeyvaultpolicies)
 * - Storage: monitoringDataStorageModule (monitoringdatastorage)
 * - Monitoring: logAnalyticsModule (loganalytics), networkWatcherModule (networkwatcher)
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

// ==================================== Resource properties ====================================

param devopsKeyVaultNameSuffix string
param devopsKeyVaultEnablePurgeProtection bool
param devopsKeyVaultSoftDeleteRetentionDays int
param devopsKeyVaultEnableRbacAuthorization bool
param devopsKeyVaultEnableArmAccess bool

// ==================================== Diagnostics options ====================================

param devopsKeyVaultEnableDiagnostics bool
param devopsKeyVaultWorkspaceName string
param devopsKeyVaultLogsRetentionDays int

// ==================================== Resource Locks switches ====================================

param devopsKeyVaultEnableLock bool

// ==================================== PaaS Firewall settings ====================================

param devopsKeyVaultEnablePublicAccess bool
param devopsKeyVaultBypassAzureServices bool
param devopsKeyVaultAllowedSubnets array
param devopsKeyVaultAllowedIPsOrCIDRs array

// ==================================== Tags ====================================

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
param standardTags object

// ==================================== Resources ====================================

module devopsKeyVaultModule 'modules/keyvault.bicep' = {
  name: 'devopsKeyVaultModule'
  params: {
    location: location
    env: env
    keyVaultNameSuffix: devopsKeyVaultNameSuffix
    enablePurgeProtection: devopsKeyVaultEnablePurgeProtection
    softDeleteRetentionDays: devopsKeyVaultSoftDeleteRetentionDays
    enableRbacAuthorization: devopsKeyVaultEnableRbacAuthorization
    enableArmAccess: devopsKeyVaultEnableArmAccess
    enableDiagnostics: devopsKeyVaultEnableDiagnostics
    diagnosticsWorkspaceName: devopsKeyVaultWorkspaceName
    logsRetentionDays: devopsKeyVaultLogsRetentionDays
    enableLock: devopsKeyVaultEnableLock
    enablePublicAccess: devopsKeyVaultEnablePublicAccess
    bypassAzureServices: devopsKeyVaultBypassAzureServices
    allowedSubnets: devopsKeyVaultAllowedSubnets
    allowedIPsOrCIDRs: devopsKeyVaultAllowedIPsOrCIDRs
    standardTags: standardTags
  }
}
