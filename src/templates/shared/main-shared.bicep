/**
 * Template: shared/main-shared
 * Modules:
 * - IAM:
 *     users-rbac-module, managed-identities-module, managed-identities-rbac-module,
 *     monitoring-loganalytics-workspace-rbac-module, keyvault-rbac-module
 * - Network:
 *     shared-network-references-module, keyvault-private-endpoint-module,
 *     flowlogs-nsg-reference-module, service-endpoint-policies-module
 * - Security: keyvault-module, keyvault-objects-module, keyvault-policies-module
 * - Storage: monitoring-storage-account-module, monitoring-storage-account-containers-module
 * - Monitoring: monitoring-loganalytics-workspace-module, flowlogs-module
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

@description('ID of the BRS Shared Services Subscription.')
param brsSubscriptionId string

@description('Name of the Resource Group for network resources in BRS Shared Services Subscription.')
param brsNetworkResourceGroupName string

@description('ID of the Prod / Non Prod Subscription.')
param prodSubscriptionId string

@description('Name of the Resource Group for network resources in Prod / Non Prod Subscription.')
param prodNetworkResourceGroupName string

@description('Name of the Apps Shared 03 VNet.')
param appsShared3VNetName string

@description('Name of the AKS VNet.')
param aksVNetName string

@description('Name of the BRS Private Endpoints VNet.')
param endpointsVNetName string

@description('Name of the MEX Private Endpoints Subnet.')
param endpointsSubnetName string

@description('Name of the Apps Shared 02 VNet.')
param appsShared2VNetName string

@description('Name of the Jump Servers Subnet.')
param jumpServersSubnetName string

@description('Name of the DevOps Agents Subnet.')
param devopsAgentsSubnetName string

@description('Name of the NSG attached to AKS Subnet.')
param aksNSGName string

// ==================================== Private Endpoints settings ====================================

@description('Private IP address of Private Endpoint used by Key Vault.')
param keyVaultPEPrivateIPAddress string

// ==================================== Resource properties ====================================

@description('Suffix used in the monitoring Storage Account name.')
@minLength(6)
@maxLength(6)
param monitoringStorageAccountNameSuffix string
@description('SKU name of the monitoring Storage Account.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
param monitoringStorageAccountSkuName string

@description('SKU name of the monitoring Workspace.')
@allowed([
  'PerGB2018'
  'CapacityReservation'
])
param monitoringWorkspaceSkuName string
@description('Capacity reservation in GBs for the monitoring Workspace.')
param monitoringWorkspaceCapacityReservation int
@description('Retention days of logs managed by monitoring Workspace.')
param monitoringWorkspaceLogRetentionDays int

@description('Suffix used in the infastructure Key Vault name.')
@minLength(6)
@maxLength(6)
param keyVaultNameSuffix string
@description('Enable purge protection feature of the Key Vault.')
param keyVaultEnablePurgeProtection bool
@description('Retention days of soft-deleted objects in the Key Vault.')
param keyVaultSoftDeleteRetentionDays int
@description('Enable ARM to access objects in the Key Vault.')
param keyVaultEnableArmAccess bool
@description('Enable RBAC authorization in Key Vault and ignore access policies.')
param keyVaultEnableRbacAuthorization bool

@description('Create Encryption Keys in Key Vault.')
param createEncryptionKeysInKeyVault bool
@description('Issue datetime of the generated Encryption Keys.')
param encryptionKeysIssueDateTime string
@description('Create Secrets in Key Vault.')
param createSecretsInKeyVault bool
@description('Enable random password generation for Secrets.')
param enableRandomPasswordGenerationForSecrets bool
@secure()
param secrtsSqlDatabaseSqlAdminLoginName string
@description('Value of the sqlAdminLoginPass Secret. Optional, can be autogenerated.')
@secure()
param secrtsSqlDatabaseSqlAdminLoginPass string
@description('Issue datetime of the generated Secrets.')
param secrtsIssueDateTime string
@description('Principal IDs of the system administrator users.')
param adminUsersPrincipalIds array
@description('Principal IDs of the developer users.')
param devUsersPrincipalIds array
@description('Principal IDs of Azure services with Key Vault access.')
param azureServicesPrincipalIds array
@description('Principal ID of the DevOps Agent AD Identity.')
param devopsAgentPrincipalId string

@description('Enable Network Watcher Flow Analytics feature. Must be enabled in the Subscription.')
param flowLogsEnableNetworkWatcherFlowAnalytics bool
@description('Retention days of flow logs captured by the Network Watcher.')
param flowLogsRetentionDays int

// ==================================== Diagnostics options ====================================

@description('Enable diagnostics to store Key Vault audit logs.')
param keyVaultEnableDiagnostics bool
@description('Retention days of the Key Vault audit logs. Must be defined if enableDiagnostics is true.')
param keyVaultLogsRetentionDays int

// ==================================== Resource Locks switches ====================================

@description('Enable Resource Lock on Flow Logs resources.')
param flowLogsEnableLock bool
@description('Enable Resource Lock on monitoring Storage Account.')
param monitoringStorageAccountEnableLock bool
@description('Enable Resource Lock on monitoring Workspace.')
param monitoringWorkspaceEnableLock bool
@description('Enable Resource Lock on Key Vault.')
param keyVaultEnableLock bool

// ==================================== PaaS Firewall settings ====================================

@description('Enable public access in the PaaS firewall.')
param monitoringStorageAccountEnablePublicAccess bool
@description('Allow bypass of PaaS firewall rules to Azure Services.')
param monitoringStorageAccountBypassAzureServices bool
@description('List of Subnet IDs allowed to access the Storage Account in the PaaS firewall.')
param monitoringStorageAccountAllowedSubnetIds array
@description('List of IPs or CIDRs allowed to access the Storage Account in the PaaS firewall.')
param monitoringStorageAccountAllowedIPsOrCIDRs array

@description('Enable public access in the PaaS firewall.')
param keyVaultEnablePublicAccess bool
@description('Allow bypass of PaaS firewall rules to Azure Services.')
param keyVaultBypassAzureServices bool
@description('List of Subnet IDs allowed to access the Storage Account in the PaaS firewall.')
param keyVaultAllowedSubnetIds array
@description('List of IPs or CIDRs allowed to access the Storage Account in the PaaS firewall.')
param keyVaultAllowedIPsOrCIDRs array

// ==================================== Module switches ====================================

@description('Create or update Private Endpoint modules.')
param enablePrivateEndpointModules bool

@description('Create or update Flow Logs module.')
param enableFlowLogsModule bool

@description('Create or update Service Endpoints Policies module.')
param enableServiceEndpointPoliciesModule bool

// ==================================== Resources ====================================

module usersRbacModule 'modules/users-rbac.bicep' = {
  name: 'users-rbac-module'
  params: {
    adminUsersPrincipalIds: adminUsersPrincipalIds
    devUsersPrincipalIds: devUsersPrincipalIds
  }
}

module managedIdentitiesModule 'modules/managed-identities.bicep' = {
  name: 'managed-identities-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
  }
}

module managedIdentitiesRbacModule 'modules/managed-identities-rbac.bicep' = {
  name: 'managed-identities-rbac-module'
  params: {
    aksManagedIdentityPrincipalId: managedIdentitiesModule.outputs.aksManagedIdentityPrincipalId
    app1ManagedIdentityPrincipalId: managedIdentitiesModule.outputs.app1ManagedIdentityPrincipalId
  }
}

module sharedNetworkReferencesModule 'modules/shared-network-references.bicep' = {
  name: 'shared-network-references-module'
  params: {
    brsSubscriptionId: brsSubscriptionId
    brsNetworkResourceGroupName: brsNetworkResourceGroupName
    prodSubscriptionId: prodSubscriptionId
    prodNetworkResourceGroupName: prodNetworkResourceGroupName
    appsShared3VNetName: appsShared3VNetName
    aksVNetName: aksVNetName
    endpointsVNetName: endpointsVNetName
    endpointsSubnetName: endpointsSubnetName
    appsShared2VNetName: appsShared2VNetName
    jumpServersSubnetName: jumpServersSubnetName
    devopsAgentsSubnetName: devopsAgentsSubnetName
  }
}

var linkedVNetIdsForPrivateEndpoints = [
  sharedNetworkReferencesModule.outputs.appsShared3VNetId
  sharedNetworkReferencesModule.outputs.aksVNetId
  sharedNetworkReferencesModule.outputs.endpointsVNetId
  sharedNetworkReferencesModule.outputs.appsShared2VNetId
]

module monitoringStorageAccountModule 'modules/monitoring-storage-account.bicep' = {
  name: 'monitoring-storage-account-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
    storageAccountNameSuffix: monitoringStorageAccountNameSuffix
    storageAccountSkuName: monitoringStorageAccountSkuName
    enableLock: monitoringStorageAccountEnableLock
    enablePublicAccess: monitoringStorageAccountEnablePublicAccess
    bypassAzureServices: monitoringStorageAccountBypassAzureServices
    allowedSubnetIds: concat(monitoringStorageAccountAllowedSubnetIds, [
        sharedNetworkReferencesModule.outputs.jumpServersSubnetId
        sharedNetworkReferencesModule.outputs.devopsAgentsSubnetId
      ])
    allowedIPsOrCIDRs: monitoringStorageAccountAllowedIPsOrCIDRs
  }
}

module monitoringStorageAccountContainersModule 'modules/monitoring-storage-account-containers.bicep' = {
  name: 'monitoring-storage-account-containers-module'
  params: {
    monitoringStorageAccountName: monitoringStorageAccountModule.outputs.storageAccountName
  }
}

module monitoringLogAnalyticsWorkspaceModule 'modules/monitoring-loganalytics-workspace.bicep' = {
  name: 'monitoring-loganalytics-workspace-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
    workspaceSkuName: monitoringWorkspaceSkuName
    workspaceCapacityReservation: monitoringWorkspaceCapacityReservation
    logRetentionDays: monitoringWorkspaceLogRetentionDays
    linkedStorageAccountName: monitoringStorageAccountModule.outputs.storageAccountName
    enableLock: monitoringWorkspaceEnableLock
  }
}

module monitoringLogAnalyticsWorkspaceRbacModule 'modules/monitoring-loganalytics-workspace-rbac.bicep' = {
  name: 'monitoring-loganalytics-workspace-rbac-module'
  params: {
    monitoringWorkspacePrincipalId: monitoringLogAnalyticsWorkspaceModule.outputs.workspacePrincipalId
  }
}

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'keyvault-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
    keyVaultNameSuffix: keyVaultNameSuffix
    enablePurgeProtection: keyVaultEnablePurgeProtection
    softDeleteRetentionDays: keyVaultSoftDeleteRetentionDays
    enableArmAccess: keyVaultEnableArmAccess
    enableRbacAuthorization: keyVaultEnableRbacAuthorization
    enableDiagnostics: keyVaultEnableDiagnostics
    diagnosticsWorkspaceName: monitoringLogAnalyticsWorkspaceModule.outputs.workspaceName
    logsRetentionDays: keyVaultLogsRetentionDays
    enableLock: keyVaultEnableLock
    enablePublicAccess: keyVaultEnablePublicAccess
    bypassAzureServices: keyVaultBypassAzureServices
    allowedSubnetIds: keyVaultAllowedSubnetIds
    allowedIPsOrCIDRs: keyVaultAllowedIPsOrCIDRs
  }
}

module keyVaultPrivateEndpointModule 'modules/private-endpoint.bicep' = if (enablePrivateEndpointModules) {
  name: 'keyvault-private-endpoint-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointNameSuffix: 'PE02'
    subnetId: sharedNetworkReferencesModule.outputs.endpointsSubnetId
    privateIPAddresses: [ keyVaultPEPrivateIPAddress ]
    serviceId: keyVaultModule.outputs.keyVaultId
    groupId: 'vault'
    linkedVNetIds: linkedVNetIdsForPrivateEndpoints
  }
}

module keyVaultObjectsModule 'modules/keyvault-objects.bicep' = {
  name: 'keyvault-objects-module'
  params: {
    location: location
    keyVaultName: keyVaultModule.outputs.keyVaultName
    createEncryptionKeys: createEncryptionKeysInKeyVault
    appsStorageAccountEncryptionKeyName: 'crececonsdx-appsstorageaccount-key'
    encryptionKeysIssueDateTime: encryptionKeysIssueDateTime
    createSecrets: createSecretsInKeyVault
    enableRandomPasswordsGeneration: enableRandomPasswordGenerationForSecrets
    sqlDatabaseSqlAdminNameSecretName: 'crececonsdx-sqldatabase-sqladminloginname'
    sqlDatabaseSqlAdminNameSecretValue: secrtsSqlDatabaseSqlAdminLoginName
    sqlDatabaseSqlAdminPassSecretName: 'crececonsdx-sqldatabase-sqladminloginpass'
    sqlDatabaseSqlAdminPassSecretValue: secrtsSqlDatabaseSqlAdminLoginPass
    secrtsIssueDateTime: secrtsIssueDateTime
  }
}

var devopsAgentPrincipalIdList = (devopsAgentPrincipalId == '') ? [] : [ devopsAgentPrincipalId ]
var keyVaultAdminsPrincipalIds = concat(adminUsersPrincipalIds, azureServicesPrincipalIds, devopsAgentPrincipalIdList)

module keyVaultPoliciesModule 'modules/keyvault-policies.bicep' = {
  name: 'keyvault-policies-module'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    appGatewayPrincipalId: managedIdentitiesModule.outputs.appGatewayManagedIdentityPrincipalId
    appsStorageAccountPrincipalId: managedIdentitiesModule.outputs.appsStorageAccountManagedIdentityPrincipalId
    adminsPrincipalIds: keyVaultAdminsPrincipalIds
    readersPrincipalIds: [
      managedIdentitiesModule.outputs.app1ManagedIdentityPrincipalId
    ]
  }
}

module keyVaultRbacModule 'modules/keyvault-rbac.bicep' = {
  name: 'keyvault-rbac-module'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    appGatewayManagedIdentityPrincipalId: managedIdentitiesModule.outputs.appGatewayManagedIdentityPrincipalId
    appsStorageAccountManagedIdentityPrincipalId: managedIdentitiesModule.outputs.appsStorageAccountManagedIdentityPrincipalId
  }
}

module flowLogsNsgModule 'modules/flowlogs-nsg-reference.bicep' = if (enableFlowLogsModule) {
  name: 'flowlogs-nsg-reference-module'
  params: {
    prodSubscriptionId: prodSubscriptionId
    prodNetworkResourceGroupName: prodNetworkResourceGroupName
    flowLogsTargetNSGName: aksNSGName
  }
}

module flowLogsModule 'modules/flowlogs.bicep' = if (enableFlowLogsModule) {
  name: 'flowlogs-module'
  scope: resourceGroup('NetworkWatcherRG')
  params: {
    location: location
    env: env
    standardTags: standardTags
    flowLogsTargetNSGId: flowLogsNsgModule.outputs.flowLogsTargetNSGId
    flowLogsStorageAccountId: monitoringStorageAccountModule.outputs.storageAccountId
    enableNetworkWatcherFlowAnalytics: flowLogsEnableNetworkWatcherFlowAnalytics
    flowAnalyticsWorkspaceId: monitoringLogAnalyticsWorkspaceModule.outputs.workspaceId
    flowLogsRetentionDays: flowLogsRetentionDays
    enableLock: flowLogsEnableLock
  }
}

module serviceEndpointPoliciesModule 'modules/service-endpoint-policies.bicep' = if (enableServiceEndpointPoliciesModule) {
  name: 'service-endpoint-policies-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
    keyVaultId: keyVaultModule.outputs.keyVaultId
    monitoringStorageAccountId: monitoringStorageAccountModule.outputs.storageAccountId
  }
}
