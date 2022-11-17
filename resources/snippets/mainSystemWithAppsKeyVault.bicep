/**
 * Template: system/mainSystem
 * Modules:
 * - IAM: teamUsersModule (teamusers), appsManagedIdsModule (appsmanagedids), teamRgRbacModule (teamrg-rbac), appsKeyVaultRbacModule (appskeyvault-rbac)
 * - Network: appGatewayModule (agw), appsKeyVaultPrivateEndpointModule (privateendpoint), appsDataStoragePrivateEndpointModule (privateendpoint), sqlDatabasePrivateEndpointModule (privateendpoint), acrPrivateEndpointModule (privateendpoint)
 * - Monitoring: networkWatcherModule (networkwatcher)
 * - Security: appsKeyVaultModule (appskeyvault), appsKeyVaultObjectsModule (appskeyvaultobjects), appsKeyVaultPoliciesModule (appskeyvaultpolicies), appsKeyVaultRbacModule (appskeyvault-rbac)
 * - Storage: appsDataStorageModule (appsdatastorage)
 * - Databases: sqlDatabaseModule (sqldatabase)
 * - Frontend: acrModule (acr), aksModule (aks)
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

// ==================================== Network dependencies ====================================

@description('Name of the Gateway VNet. Must be defined when enableNetwork is false.')
param gatewayVNetName string

@description('Name of the Gateway Subnet. Must be defined when enableNetwork is false.')
param gatewaySubnetName string

@description('Name of the Applications VNet. Must be defined when enableNetwork is false.')
param appsVNetName string

@description('Name of the Applications Subnet. Must be defined when enableNetwork is false.')
param appsSubnetName string

@description('Name of the Endpoints VNet. Must be defined when enableNetwork is false.')
param endpointsVNetName string

@description('Name of the Endpoints Subnet. Must be defined when enableNetwork is false.')
param endpointsSubnetName string

@description('Name of the Jump Servers VNet. Must be defined when enableNetwork is false.')
param jumpServersVNetName string

@description('Name of the DevOps Agents VNet. Must be defined when enableNetwork is false.')
param devopsAgentsVNetName string

@description('Name of the NSG attached to Applications Subnet. Must be defined when enableNetwork is false.')
param appsNSGName string

// ==================================== Private Endpoints settings ====================================

@description('Create Private Endpoints for the required modules like appskeyvault, appsdatastorage, sqldatabase and acr.')
param enablePrivateEndpoints bool = true

@description('Private IP address of Private Endpoint used by Key Vault for applications.')
param appsKeyVaultPEPrivateIPAddress string

@description('Private IP address of Private Endpoint used by applications data Storage Account.')
param appsDataStoragePEPrivateIPAddress string

@description('Private IP address of Private Endpoint used by Azure SQL Database.')
param sqlDatabasePEPrivateIPAddress string

@description('Private IPs oaddresses of Private Endpoint used by Container Registry. Requires 2 IPs for 2 members: registry and registry_data.')
param acrPEPrivateIPAddresses array

// ==================================== Monitoring dependencies ====================================

param monitoringDataStorageAccountName string

param monitoringWorkspaceName string

// ==================================== Security dependencies ====================================

@secure()
param administratorPrincipalId string

param appGatewayManageIdentityName string
param appsDataStorageManagedIdentityName string
param aksManagedIdentityName string

param infraKeyVaultUri string

param appGatewayPublicCertificateId string
param appGatewayPrivateCertificateId string

param appsDataStorageEncryptionKeyName string

@secure()
param sqlDatabaseSqlAdminLoginName string
@secure()
param sqlDatabaseSqlAdminLoginPass string
@secure()
param sqlDatabaseAADAdminLoginName string

// ==================================== Resource properties ====================================

param enableFlowLogs bool
param flowLogsRetentionDays int

param appsKeyVaultNameSuffix string
param appsKeyVaultEnablePurgeProtection bool
param appsKeyVaultSoftDeleteRetentionDays int
param appsKeyVaultEnableArmAccess bool
param appsKeyVaultEnableRbacAuthorization bool

param appGatewayNameSuffix string
param appGatewaySkuTier string
param appGatewaySkuName string
param appGatewayFrontendPrivateIPAddress string
param appGatewayEnablePublicFrontendIP bool
param appGatewayAutoScaleMinCapacity int
param appGatewayAutoScaleMaxCapacity int
param appGatewayEnableHttpPort bool
param appGatewayEnableHttpsPort bool
param appGatewayWafPoliciesMode string

param appsDataStorageNameSuffix string
param appsDataStorageSkuName string

param sqlServerNameSuffix string
param sqlDatabaseSkuType string
param sqlDatabaseSkuSize int
param sqlDatabaseMinCapacity int
param sqlDatabaseMaxSizeGB int
param sqlDatabaseZoneRedundant bool
param sqlDatabaseBackupRedundancy string

param acrNameSuffix string
param acrSku string
param acrZoneRedundancy string
param acrUntaggedRetentionDays int
param acrSoftDeleteRetentionDays int

param aksSkuTier string
param aksDnsSuffix string
param aksKubernetesVersion string
param aksEnableAutoScaling bool
param aksNodePoolMinCount int
param aksNodePoolMaxCount int
param aksNodePoolVmSize string
param aksEnableEncryptionAtHost bool
param aksEnablePrivateCluster bool
param aksEnablePodManagedIdentity bool
param aksPodIdentities array
param aksEnableWorkloadIdentity bool
param aksEnableAGICAddon bool
param aksEnableOMSAgentAddon bool

// ==================================== Diagnostics options ====================================

param appsKeyVaultEnableDiagnostics bool
param appsKeyVaultLogsRetentionDays int

param appGatewayEnableDiagnostics bool
param appGatewayLogsRetentionDays int

param appsDataStorageEnableDiagnostics bool
param appsDataStorageLogsRetentionDays int

param sqlDatabaseEnableAuditing bool
param sqlDatabaseAuditLogsRetentionDays int
param sqlDatabaseEnableThreatProtection bool
param sqlDatabaseEnableVulnerabilityAssessments bool

param acrEnableDiagnostics bool
param acrLogsRetentionDays int

// ==================================== Resource Locks switches ====================================

param networkWatcherEnableLock bool
param appsKeyVaultEnableLock bool
param appGatewayEnableLock bool
param appsDataStorageEnableLock bool
param sqlDatabaseEnableLock bool
param acrEnableLock bool
param aksEnableLock bool

// ==================================== PaaS Firewall settings ====================================

param appsKeyVaultEnablePublicAccess bool
param appsKeyVaultBypassAzureServices bool
param appsKeyVaultAllowedSubnets array
param appsKeyVaultAllowedIPsOrCIDRs array

param appsDataStorageEnablePublicAccess bool
param appsDataStorageBypassAzureServices bool
param appsDataStorageAllowedSubnets array
param appsDataStorageAllowedIPsOrCIDRs array

param sqlDatabaseEnablePublicAccess bool
param sqlDatabaseAllowedSubnets array
param sqlDatabaseAllowedIPRanges array

param acrEnablePublicAccess bool
param acrBypassAzureServices bool
param acrAllowedIPsOrCIDRs array

param aksEnablePublicAccess bool

// ==================================== Modules ====================================

module appsKeyVaultModule 'modules/appsKeyVault.bicep' = {
  name: 'appsKeyVaultModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    keyVaultNameSuffix: appsKeyVaultNameSuffix
    enablePurgeProtection: appsKeyVaultEnablePurgeProtection
    softDeleteRetentionDays: appsKeyVaultSoftDeleteRetentionDays
    enableArmAccess: appsKeyVaultEnableArmAccess
    enableRbacAuthorization: appsKeyVaultEnableRbacAuthorization
    enableDiagnostics: appsKeyVaultEnableDiagnostics
    diagnosticsWorkspaceName: monitoringWorkspaceName
    logsRetentionDays: appsKeyVaultLogsRetentionDays
    enableLock: appsKeyVaultEnableLock
    enablePublicAccess: appsKeyVaultEnablePublicAccess
    bypassAzureServices: appsKeyVaultBypassAzureServices
    allowedSubnets: appsKeyVaultAllowedSubnets
    allowedIPsOrCIDRs: appsKeyVaultAllowedIPsOrCIDRs
  }
}

module appsKeyVaultPrivateEndpointModule 'modules/privateEndpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'appsKeyVaultPrivateEndpointModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointName: 'PE02'
    vnetName: selectedNetworkNames.endpointsVNetName
    subnetName: selectedNetworkNames.endpointsSubnetName
    privateIPAddresses: [ appsKeyVaultPEPrivateIPAddress ]
    serviceId: appsKeyVaultModule.outputs.keyVaultId
    groupId: 'vault'
    linkedVNetNames: selectedLinkedVNetNames
  }
}

module appsKeyVaultObjectsModule 'modules/appsKeyVaultObjects.bicep' = {
  name: 'appsKeyVaultObjectsModule'
  params: {
    location: location
    keyVaultName: appsKeyVaultModule.outputs.keyVaultName
  }
}

module appsKeyVaultPoliciesModule 'modules/appsKeyVaultPolicies.bicep' = {
  name: 'appsKeyVaultPoliciesModule'
  params: {
    keyVaultName: appsKeyVaultModule.outputs.keyVaultName
    applicationsPrincipalIds: []
    teamPrincipalIds: []
  }
}
