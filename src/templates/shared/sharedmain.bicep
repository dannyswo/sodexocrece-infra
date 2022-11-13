/**
 * Template: shared/main
 * Modules:
 * - IAM: infraUsersModule (infrausers), infraManagedIdsModule (inframanagedids), infraRgRbacModule (infrarg-rbac), infraKeyVaultRbacModule (infrakeyvault-rbac)
 * - Security: infraKeyVaultModule (infrakeyvault), infraKeyVaultObjectsModule (infrakeyvaultobjects), infraKeyVaultPoliciesModule (infrakeyvaultpolicies), infraKeyVaultRbacModule (infrakeyvault-rbac)
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

// ==================================== Resource properties ====================================

param infraKeyVaultNameSuffix string
param infraKeyVaultEnablePurgeProtection bool
param infraKeyVaultSoftDeleteRetentionDays int
param infraKeyVaultEnableRbacAuthorization bool
param infraKeyVaultEnableArmAccess bool

// ==================================== Diagnostics options ====================================

param infraKeyVaultEnableDiagnostics bool
param infraKeyVaultWorkspaceName string
param infraKeyVaultLogsRetentionDays int

// ==================================== Resource Locks switches ====================================

param infraKeyVaultEnableLock bool

// ==================================== PaaS Firewall settings ====================================

param infraKeyVaultEnablePublicAccess bool
param infraKeyVaultBypassAzureServices bool
param infraKeyVaultAllowedSubnets array
param infraKeyVaultAllowedIPsOrCIDRs array

// ==================================== Resources ====================================

