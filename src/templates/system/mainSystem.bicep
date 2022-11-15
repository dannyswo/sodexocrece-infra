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

@description('Name of the Gateway VNet.')
param gatewayVNetName string

@description('Name of the Gateway Subnet.')
param gatewaySubnetName string

@description('Name of the Applications VNet.')
param appsVNetName string

@description('Name of the Applications Subnet.')
param appsSubnetName string

@description('Name of the Endpoints VNet.')
param endpointsVNetName string

@description('Name of the Endpoints Subnet.')
param endpointsSubnetName string

@description('Name of the Jump Servers VNet.')
param jumpServersVNetName string

@description('Name of the DevOps Agents VNet.')
param devopsAgentsVNetName string

@description('Name of the NSG attached to Applications Subnet.')
param appsNSGName string

// ==================================== Private Endpoints settings ====================================

@description('Create Private Endpoints for the required modules like appskeyvault, appsdatastorage, sqldatabase and acr.')
param enablePrivateEndpoints bool = true

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
param appGatewayEnableLock bool
param appsDataStorageEnableLock bool
param sqlDatabaseEnableLock bool
param acrEnableLock bool
param aksEnableLock bool

// ==================================== PaaS Firewall settings ====================================

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

module teamUsersModule 'modules/teamUsers.bicep' = {
  name: 'teamUsersModule'
  params: {
  }
}

module appsManagedIdsModule 'modules/appsManagedIds.bicep' = {
  name: 'appsManagedIdsModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
  }
}

module teamRgRbacModule 'modules/teamRgRbac.bicep' = {
  name: 'teamRgRbacModule'
  params: {
  }
}

var selectedNetworkNames = {
  gatewayVNetName: gatewayVNetName
  gatewaySubnetName: gatewaySubnetName
  appsVNetName: appsVNetName
  appsSubnetName: appsSubnetName
  endpointsVNetName: endpointsVNetName
  endpointsSubnetName: endpointsSubnetName
}

var selectedLinkedVNetNames = [
  gatewayVNetName
  appsVNetName
  endpointsVNetName
  jumpServersVNetName
  devopsAgentsVNetName
]

var selectedAksPrivateDnsZoneLinkedVNetNames = [
  appsVNetName
  jumpServersVNetName
  devopsAgentsVNetName
]

var selectedNSGNames = {
  appsNSGName: appsNSGName
}

module networkWatcherModule 'modules/networkWatcher.bicep' = if (enableFlowLogs) {
  name: 'networkWatcherModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    targetNSGName: selectedNSGNames.appsNSGName
    flowLogsStorageAccountName: monitoringDataStorageAccountName
    flowAnalyticsWorkspaceName: monitoringWorkspaceName
    flowLogsRetentionDays: flowLogsRetentionDays
    enableLock: networkWatcherEnableLock
  }
}

module appGatewayModule 'modules/agw.bicep' = {
  name: 'appGatewayModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    managedIdentityName: appGatewayManageIdentityName
    appGatewayNameSuffix: appGatewayNameSuffix
    appGatewaySkuTier: appGatewaySkuTier
    appGatewaySkuName: appGatewaySkuName
    gatewayVNetName: selectedNetworkNames.gatewayVNetName
    gatewaySubnetName: selectedNetworkNames.gatewaySubnetName
    frontendPrivateIPAddress: appGatewayFrontendPrivateIPAddress
    enablePublicFrontendIP: appGatewayEnablePublicFrontendIP
    autoScaleMinCapacity: appGatewayAutoScaleMinCapacity
    autoScaleMaxCapacity: appGatewayAutoScaleMaxCapacity
    enableHttpPort: appGatewayEnableHttpPort
    enableHttpsPort: appGatewayEnableHttpsPort
    publicCertificateId: appGatewayPublicCertificateId
    privateCertificateId: appGatewayPrivateCertificateId
    wafPoliciesMode: appGatewayWafPoliciesMode
    enableDiagnostics: appGatewayEnableDiagnostics
    diagnosticsWorkspaceName: monitoringWorkspaceName
    logsRetentionDays: appGatewayLogsRetentionDays
    enableLock: appGatewayEnableLock
  }
}

module appsDataStorageModule 'modules/appsDataStorage.bicep' = {
  name: 'appsDataStorageModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    managedIdentityName: appsDataStorageManagedIdentityName
    storageAccountNameSuffix: appsDataStorageNameSuffix
    storageAccountSkuName: appsDataStorageSkuName
    keyVaultUri: infraKeyVaultUri
    encryptionKeyName: appsDataStorageEncryptionKeyName
    enableDiagnostics: appsDataStorageEnableDiagnostics
    diagnosticsWorkspaceName: monitoringWorkspaceName
    logsRetentionDays: appsDataStorageLogsRetentionDays
    enableLock: appsDataStorageEnableLock
    enablePublicAccess: appsDataStorageEnablePublicAccess
    bypassAzureServices: appsDataStorageBypassAzureServices
    allowedSubnets: appsDataStorageAllowedSubnets
    allowedIPsOrCIDRs: appsDataStorageAllowedIPsOrCIDRs
  }
}

module appsDataStorageContainersModule 'modules/appsDataStorageContainers.bicep' = {
  name: 'appsDataStorageContainersModule'
  params: {
    appsDataStorageAccountName: appsDataStorageModule.outputs.storageAccountName
  }
}

module appsDataStoragePrivateEndpointModule 'modules/privateEndpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'appsDataStoragePrivateEndpointModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointName: 'PE04'
    vnetName: selectedNetworkNames.endpointsVNetName
    subnetName: selectedNetworkNames.endpointsSubnetName
    privateIPAddresses: [ appsDataStoragePEPrivateIPAddress ]
    serviceId: appsDataStorageModule.outputs.storageAccountId
    groupId: 'blob'
    linkedVNetNames: selectedLinkedVNetNames
  }
}

module sqlDatabaseModule 'modules/sqlDatabase.bicep' = {
  name: 'sqlDatabaseModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    sqlServerNameSuffix: sqlServerNameSuffix
    sqlAdminLoginName: sqlDatabaseSqlAdminLoginName
    sqlAdminLoginPass: sqlDatabaseSqlAdminLoginPass
    aadAdminPrincipalId: administratorPrincipalId
    aadAdminLoginName: sqlDatabaseAADAdminLoginName
    skuType: sqlDatabaseSkuType
    skuSize: sqlDatabaseSkuSize
    minCapacity: sqlDatabaseMinCapacity
    maxSizeGB: sqlDatabaseMaxSizeGB
    zoneRedundant: sqlDatabaseZoneRedundant
    backupRedundancy: sqlDatabaseBackupRedundancy
    enableAuditing: sqlDatabaseEnableAuditing
    diagnosticsWorkspaceName: monitoringWorkspaceName
    logsRetentionDays: sqlDatabaseAuditLogsRetentionDays
    enableThreatProtection: sqlDatabaseEnableThreatProtection
    enableVulnerabilityAssessments: sqlDatabaseEnableVulnerabilityAssessments
    enableLock: sqlDatabaseEnableLock
    enablePublicAccess: sqlDatabaseEnablePublicAccess
    allowedSubnets: sqlDatabaseAllowedSubnets
    allowedIPRanges: sqlDatabaseAllowedIPRanges
  }
}

module sqlDatabasePrivateEndpointModule 'modules/privateEndpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'sqlDatabasePrivateEndpointModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointName: 'PE01'
    vnetName: selectedNetworkNames.endpointsVNetName
    subnetName: selectedNetworkNames.endpointsSubnetName
    privateIPAddresses: [ sqlDatabasePEPrivateIPAddress ]
    serviceId: sqlDatabaseModule.outputs.sqlServerId
    groupId: 'sqlServer'
    linkedVNetNames: selectedLinkedVNetNames
  }
}

module acrModule 'modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    acrNameSuffix: acrNameSuffix
    acrSku: acrSku
    zoneRedundancy: acrZoneRedundancy
    untaggedRetentionDays: acrUntaggedRetentionDays
    softDeleteRetentionDays: acrSoftDeleteRetentionDays
    enableDiagnostics: acrEnableDiagnostics
    diagnosticsWorkspaceName: monitoringWorkspaceName
    logsRetentionDays: acrLogsRetentionDays
    enableLock: acrEnableLock
    enablePublicAccess: acrEnablePublicAccess
    bypassAzureServices: acrBypassAzureServices
    allowedIPsOrCIDRs: acrAllowedIPsOrCIDRs
  }
}

module acrPrivateEndpointModule 'modules/privateEndpoint.bicep' = if (enablePrivateEndpoints) {
  name: 'acrPrivateEndpointModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointName: 'PE03'
    vnetName: selectedNetworkNames.endpointsVNetName
    subnetName: selectedNetworkNames.endpointsSubnetName
    privateIPAddresses: acrPEPrivateIPAddresses
    serviceId: acrModule.outputs.registryId
    groupId: 'registry'
    linkedVNetNames: selectedLinkedVNetNames
  }
}

module aksModule 'modules/aks.bicep' = {
  name: 'aksModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    managedIdentityName: aksManagedIdentityName
    aksSkuTier: aksSkuTier
    aksDnsSuffix: aksDnsSuffix
    kubernetesVersion: aksKubernetesVersion
    vnetName: selectedNetworkNames.appsVNetName
    subnetName: selectedNetworkNames.appsSubnetName
    enableAutoScaling: aksEnableAutoScaling
    nodePoolMinCount: aksNodePoolMinCount
    nodePoolMaxCount: aksNodePoolMaxCount
    nodePoolVmSize: aksNodePoolVmSize
    enableEncryptionAtHost: aksEnableEncryptionAtHost
    enablePrivateCluster: aksEnablePrivateCluster
    privateDnsZoneLinkedVNetNames: selectedAksPrivateDnsZoneLinkedVNetNames
    enablePodManagedIdentity: aksEnablePodManagedIdentity
    podIdentities: aksPodIdentities
    enableWorkloadIdentity: aksEnableWorkloadIdentity
    enableAGICAddon: aksEnableAGICAddon
    appGatewayName: appGatewayModule.outputs.applicationGatewayName
    enableOMSAgentAddon: aksEnableOMSAgentAddon
    workspaceName: monitoringWorkspaceName
    enableLock: aksEnableLock
    enablePublicAccess: aksEnablePublicAccess
  }
}
