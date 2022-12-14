/**
 * Template: shared/main-shared
 * Modules:
 * - IAM:
 *     users-rbac-module, managed-identities-module, managed-identities-rbac-module,
 *     monitoring-loganalytics-workspace-rbac-module, keyvault-rbac-module
 * - Network:
 *     network-references-shared-module, network-security-groups-module, keyvault-private-endpoint-module
 * - Security: keyvault-module, keyvault-objects-module, keyvault-policies-module
 * - Storage: monitoring-storage-account-module, monitoring-storage-account-containers-module
 * - Monitoring: monitoring-loganalytics-workspace-module
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
  AllowShutdown: 'True (for non-prod environments), False (for prod environments)'
  ApplicationName: 'BRS.LATAM.MX.Crececonsdx'
  ApplicationOwner: 'ApplicationOwner'
  ApplicationSponsor: 'ApplicationSponsor'
  dd_organization: 'MX (only for prod environments)'
  env: 'dev | uat | prd'
  EnvironmentType: 'DEV | UAT | PRD'
  Maintainer: 'SoftwareONE'
  Maintenance: '{ ... } (maintenance standard JSON)'
  Security: '{ ... } (security standard JSON generated in Palantir)'
  DeploymentDate: 'YYY-MM-DDTHHMM UTC (autogenatered)'
  stack: 'Merchant'
  TechnicalContact: 'TechnicalContact'
})
param standardTags object = resourceGroup().tags

// ==================================== Network dependencies ====================================

@description('ID of the BRS Shared Services Subscription.')
param sharedServicesSubscriptionId string

@description('Name of the DEV Resource Group for network resources in BRS Shared Services Subscription.')
param devSharedServicesNetworkResourceGroupName string

@description('Name of the PRD Resource Group for network resources in BRS Shared Services Subscription.')
param prdSharedServicesNetworkResourceGroupName string

@description('ID of the Prod / Non Prod Subscription.')
param prodSubscriptionId string

@description('Name of the Resource Group for network resources in Prod / Non Prod Subscription.')
param prodNetworkResourceGroupName string

@description('ID of the BRS Tier 0 Subscription.')
param tier0SubscriptionId string

@description('Name of the Resource Group for global DNS related resources.')
param globalDnsResourceGroupName string

@description('Name of the Frontend VNet.')
param frontendVNetName string

@description('Name of the Application Gateway Subnet.')
param gatewaySubnetName string

@description('Name of the AKS VNet.')
param aksVNetName string

@description('Name of the AKS Subnet.')
param aksSubnetName string

@description('Name of the BRS Private Endpoints VNet.')
param endpointsVNetName string

@description('Name of the MEX Private Endpoints Subnet.')
param endpointsSubnetName string

@description('Name of the Jump Servers VNet.')
param jumpServersVNetName string

@description('Name of the Jump Servers Subnet.')
param jumpServersSubnetName string

@description('Name of the DevOps Agents VNet.')
param devopsAgentsVNetName string

@description('Name of the DevOps Agents Subnet.')
param devopsAgentsSubnetName string

// ==================================== Private Endpoints settings ====================================

@description('Private IP address of Private Endpoint used by Key Vault.')
param keyVaultPEPrivateIPAddress string

@description('Create Private DNS Zone Groups for all Private Endpoints.')
param createPEDnsZoneGroups bool

@description('Create Private DNS Zones for all Private Endpoints.')
param createPEPrivateDnsZones bool

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
@description('Value of the sqlAdminLoginName Secret.')
@secure()
param secrtsSqlDatabaseSqlAdminLoginName string
@description('Value of the sqlAdminLoginPass Secret.')
@secure()
param secrtsSqlDatabaseSqlAdminLoginPass string
@description('Issue datetime of the generated Secrets.')
param secrtsIssueDateTime string
@description('Principal IDs of the system administrator AAD Users.')
param adminUsersPrincipalIds array
@description('Principal IDs of the system administrator AAD Groups.')
param adminGroupsPrincipalIds array
@description('Principal IDs of the developer AAD Users.')
param devUsersPrincipalIds array
@description('Principal IDs of Azure services with Key Vault access.')
param azureServicesPrincipalIds array
@description('Principal IDs of the DevOps Agents Managed Identity.')
param devopsAgentsPrincipalIds array

// ==================================== Diagnostics options ====================================

@description('Enable diagnostics to store Key Vault audit logs.')
param keyVaultEnableDiagnostics bool
@description('Retention days of the Key Vault audit logs. Must be defined if enableDiagnostics is true.')
param keyVaultLogsRetentionDays int

// ==================================== Resource Locks switches ====================================

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

@description('Enable Private Endpoint modules.')
param enablePrivateEndpointModules bool

@description('Enable Managed Identities Network Group RBAC module.')
param enableManagedIdentitiesNetworkGroupRbacModule bool

@description('Enable Network Security Groups module.')
param enableNetworkSecurityGroupsModule bool

// ==================================== Resources ====================================

var standardTagsWithDatadogTags = union(standardTags, {
    dd_organization: 'MX'
    countries: 'mx'
    Maintainer: 'SoftwareONE'
  })

module usersRbacModule 'modules/users-rbac.bicep' = {
  name: 'users-rbac-module'
  params: {
    adminUsersPrincipalIds: adminUsersPrincipalIds
    adminGroupsPrincipalIds: adminGroupsPrincipalIds
    devUsersPrincipalIds: devUsersPrincipalIds
  }
}

module managedIdentitiesModule 'modules/managed-identities.bicep' = {
  name: 'managed-identities-module'
  params: {
    location: location
    env: env
    standardTags: standardTagsWithDatadogTags
  }
}

module managedIdentitiesRbacModule 'modules/managed-identities-rbac.bicep' = {
  name: 'managed-identities-rbac-module'
  params: {
    aksManagedIdentityPrincipalId: managedIdentitiesModule.outputs.aksManagedIdentityPrincipalId
    containerApp1ManagedIdentityPrincipalId: managedIdentitiesModule.outputs.containerApp1ManagedIdentityPrincipalId
  }
}

module managedIdentitiesNetworkGroupRbacModule 'modules/managed-identities-networkgroup-rbac.bicep' = if (enableManagedIdentitiesNetworkGroupRbacModule) {
  name: 'managed-identities-networkgroup-rbac-module'
  scope: resourceGroup(prodSubscriptionId, prodNetworkResourceGroupName)
  params: {
    aksManagedIdentityPrincipalId: managedIdentitiesModule.outputs.aksManagedIdentityPrincipalId
  }
}

module networkReferencesSharedModule 'modules/network-references-shared.bicep' = {
  name: 'network-references-shared-module'
  params: {
    sharedServicesSubscriptionId: sharedServicesSubscriptionId
    devSharedServicesNetworkResourceGroupName: devSharedServicesNetworkResourceGroupName
    prdSharedServicesNetworkResourceGroupName: prdSharedServicesNetworkResourceGroupName
    prodSubscriptionId: prodSubscriptionId
    prodNetworkResourceGroupName: prodNetworkResourceGroupName
    tier0SubscriptionId: tier0SubscriptionId
    globalDnsResourceGroupName: globalDnsResourceGroupName
    frontendVNetName: frontendVNetName
    gatewaySubnetName: gatewaySubnetName
    aksVNetName: aksVNetName
    aksSubnetName: aksSubnetName
    endpointsVNetName: endpointsVNetName
    endpointsSubnetName: endpointsSubnetName
    jumpServersVNetName: jumpServersVNetName
    jumpServersSubnetName: jumpServersSubnetName
    devopsAgentsVNetName: devopsAgentsVNetName
    devopsAgentsSubnetName: devopsAgentsSubnetName
  }
}

module networkSecurityGroupsModule 'modules/network-security-groups.bicep' = if (enableNetworkSecurityGroupsModule) {
  name: 'network-security-groups-module'
  params: {
    location: location
    env: env
    standardTags: standardTagsWithDatadogTags
    gatewayNSGSourceAddressPrefixes: [
      networkReferencesSharedModule.outputs.jumpServersSubnetAddressPrefix
      networkReferencesSharedModule.outputs.devopsAgentsSubnetAddressPrefix
    ]
    aksNSGSourceAddressPrefixes: [
      networkReferencesSharedModule.outputs.gatewaySubnetAddressPrefix
      networkReferencesSharedModule.outputs.jumpServersSubnetAddressPrefix
      networkReferencesSharedModule.outputs.devopsAgentsSubnetAddressPrefix
    ]
  }
}

var linkedVNetIdsForPrivateEndpoints = [
  networkReferencesSharedModule.outputs.frontendVNetId
  networkReferencesSharedModule.outputs.aksVNetId
  networkReferencesSharedModule.outputs.endpointsVNetId
  networkReferencesSharedModule.outputs.jumpServersVNetId
  networkReferencesSharedModule.outputs.devopsAgentsVNetId
]

var monitoringStorageAccountDefaultAllowedSubnetIds = [
  networkReferencesSharedModule.outputs.jumpServersSubnetId
  networkReferencesSharedModule.outputs.devopsAgentsSubnetId
]

module monitoringStorageAccountModule 'modules/monitoring-storage-account.bicep' = {
  name: 'monitoring-storage-account-module'
  params: {
    location: location
    env: env
    standardTags: standardTagsWithDatadogTags
    storageAccountNameSuffix: monitoringStorageAccountNameSuffix
    storageAccountSkuName: monitoringStorageAccountSkuName
    enableLock: monitoringStorageAccountEnableLock
    enablePublicAccess: monitoringStorageAccountEnablePublicAccess
    bypassAzureServices: monitoringStorageAccountBypassAzureServices
    allowedSubnetIds: concat(monitoringStorageAccountDefaultAllowedSubnetIds, monitoringStorageAccountAllowedSubnetIds)
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
    standardTags: standardTagsWithDatadogTags
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

var keyVaultDefaultAllowedSubnetIds = [
  networkReferencesSharedModule.outputs.gatewaySubnetId
  networkReferencesSharedModule.outputs.aksSubnetId
  networkReferencesSharedModule.outputs.jumpServersSubnetId
  networkReferencesSharedModule.outputs.devopsAgentsSubnetId
]

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'keyvault-module'
  params: {
    location: location
    env: env
    standardTags: standardTagsWithDatadogTags
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
    allowedSubnetIds: concat(keyVaultDefaultAllowedSubnetIds, keyVaultAllowedSubnetIds)
    allowedIPsOrCIDRs: keyVaultAllowedIPsOrCIDRs
  }
}

module keyVaultPrivateEndpointModule 'modules/private-endpoint.bicep' = if (enablePrivateEndpointModules) {
  name: 'keyvault-private-endpoint-module'
  params: {
    location: location
    env: env
    standardTags: standardTagsWithDatadogTags
    privateEndpointNameSuffix: 'PE02'
    subnetId: networkReferencesSharedModule.outputs.endpointsSubnetId
    privateIPAddresses: [ keyVaultPEPrivateIPAddress ]
    serviceId: keyVaultModule.outputs.keyVaultId
    groupId: 'vault'
    createDnsZoneGroup: createPEDnsZoneGroups
    createPrivateDnsZone: createPEPrivateDnsZones
    externalPrivateDnsZoneId: networkReferencesSharedModule.outputs.keyVaultPrivateDnsZoneId
    linkedVNetIds: linkedVNetIdsForPrivateEndpoints
  }
}

module keyVaultObjectsModule 'modules/keyvault-objects.bicep' = {
  name: 'keyvault-objects-module'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    createEncryptionKeys: createEncryptionKeysInKeyVault
    appsStorageAccountEncryptionKeyName: 'crececonsdx-appsstorageaccount-key'
    acrEncryptionKeyName: 'crececonsdx-acr-key'
    merchantPortalEncryptionKeyName: 'crececonsdx-merchantportal-key'
    encryptionKeysIssueDateTime: encryptionKeysIssueDateTime
    createSecrets: createSecretsInKeyVault
    sqlDatabaseSqlAdminNameSecretName: 'crececonsdx-sqldatabase-sqladminloginname'
    sqlDatabaseSqlAdminNameSecretValue: secrtsSqlDatabaseSqlAdminLoginName
    sqlDatabaseSqlAdminPassSecretName: 'crececonsdx-sqldatabase-sqladminloginpass'
    sqlDatabaseSqlAdminPassSecretValue: secrtsSqlDatabaseSqlAdminLoginPass
    secrtsIssueDateTime: secrtsIssueDateTime
  }
}

var keyVaultAdminsPrincipalIds = concat(adminUsersPrincipalIds, adminGroupsPrincipalIds, azureServicesPrincipalIds, devopsAgentsPrincipalIds)
var keyVaultReadersPrincipalIds = [
  managedIdentitiesModule.outputs.containerApp1ManagedIdentityPrincipalId
]

module keyVaultPoliciesModule 'modules/keyvault-policies.bicep' = {
  name: 'keyvault-policies-module'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    appGatewayManagedIdentityPrincipalId: managedIdentitiesModule.outputs.appGatewayManagedIdentityPrincipalId
    appsStorageAccountManagedIdentityPrincipalId: managedIdentitiesModule.outputs.appsStorageAccountManagedIdentityPrincipalId
    acrManagedIdentityPrincipalId: managedIdentitiesModule.outputs.acrManagedIdentityPrincipalId
    adminsPrincipalIds: keyVaultAdminsPrincipalIds
    readersPrincipalIds: keyVaultReadersPrincipalIds
  }
}

module keyVaultRbacModule 'modules/keyvault-rbac.bicep' = {
  name: 'keyvault-rbac-module'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    appGatewayManagedIdentityPrincipalId: managedIdentitiesModule.outputs.appGatewayManagedIdentityPrincipalId
    appsStorageAccountManagedIdentityPrincipalId: managedIdentitiesModule.outputs.appsStorageAccountManagedIdentityPrincipalId
    acrManagedIdentityPrincipalId: managedIdentitiesModule.outputs.acrManagedIdentityPrincipalId
    containerApp1ManagedIdentityPrincipalId: managedIdentitiesModule.outputs.containerApp1ManagedIdentityPrincipalId
  }
}
