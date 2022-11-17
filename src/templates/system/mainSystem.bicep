/**
 * Template: system/mainSystem
 * Modules:
 * - IAM: systemUsersModule (systemUsers), systemRgRbacModule (systemRgRbac), aksRbacModule (aksRbac), aksNodeGroupRbacModule (aksNodeGroupRbac)
 * - Network: appGatewayModule (agw), appsDataStoragePrivateEndpointModule (privateEndpoint), sqlDatabasePrivateEndpointModule (privateEndpoint), acrPrivateEndpointModule (privateEndpoint)
 * - Storage: appsDataStorageModule (appsDataStorage), appsDataStorageContainersModule (appsDataStorageContainers)
 * - Databases: sqlDatabaseModule (sqlDatabase)
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

// ==================================== Private Endpoints settings ====================================

@description('Private IP address of Private Endpoint used by applications data Storage Account.')
param appsDataStoragePEPrivateIPAddress string

@description('Private IP address of Private Endpoint used by Azure SQL Database.')
param sqlDatabasePEPrivateIPAddress string

@description('Private IPs oaddresses of Private Endpoint used by Container Registry. Requires 2 IPs for 2 members: registry and registry_data.')
param acrPEPrivateIPAddresses array

// ==================================== Monitoring dependencies ====================================

@description('Name of the monitoring data Storage Account.')
param monitoringDataStorageAccountName string

@description('Name of the monitoring Workspace.')
param monitoringWorkspaceName string

// ==================================== Security dependencies ====================================

@description('Name of the Managed Identity used by the Application Gateway.')
param appGatewayManageIdentityName string
@description('Name of the Managed Identity used by applications data Storage Account.')
param appsDataStorageManagedIdentityName string
@description('Name of the Managed Identity used by the AKS Managed Cluster.')
param aksManagedIdentityName string

@description('URI of the infrastructure Key Vault.')
param infraKeyVaultUri string

@description('ID of the public SSL certificate stored in infrastructure Key Vault.')
param appGatewayPublicCertificateId string
@description('ID of the private SSL certificate stored in infrastructure Key Vault.')
param appGatewayPrivateCertificateId string

@description('Name of the Encryption Key used by applications data Storage Account.')
param appsDataStorageEncryptionKeyName string

@description('Login name of the SQL Server administrator.')
@secure()
param sqlDatabaseSqlAdminLoginName string
@description('Password of the SQL Server administrator.')
@secure()
param sqlDatabaseSqlAdminLoginPass string
@description('Register Azure AD administrator for SQL Server.')
param sqlDatabaseEnableAADAdminUser bool
@description('Login name of the Azure AD administrator for SQL Server.')
@secure()
param sqlDatabaseAADAdminLoginName string
@description('Principal ID of the Azure AD administrator for SQL Server.')
@secure()
param sqlDatabaseAADAdminPrincipalId string

// ==================================== Resource properties ====================================

@description('Suffix used in the name of the Application Gateway.')
@minLength(6)
@maxLength(6)
param appGatewayNameSuffix string
@description('SKU tier of the Application Gateway.')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param appGatewaySkuTier string
@description('SKU name of the Application Gateway.')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param appGatewaySkuName string
@description('Frontend private IP address of Application Gateway.')
param appGatewayFrontendPrivateIPAddress string
@description('Configure HTTP Listeners to receive traffic on public frontend IP. Otherwise, use private frontend IP.')
param appGatewayEnablePublicFrontendIP bool
@description('Minimum capacity for auto scaling of Application Gateway.')
param appGatewayAutoScaleMinCapacity int
@description('Maximum capacity for auto scaling of Application Gateway.')
param appGatewayAutoScaleMaxCapacity int
@description('Enable a Listener on port 80.')
param appGatewayEnableHttpPort bool
@description('Enable Listener on port 443 and setup the public SSL certificate.')
param appGatewayEnableHttpsPort bool
@description('Application Gateway WAF Policies mode.')
@allowed([
  'Detection'
  'Prevention'
])
param appGatewayWafPoliciesMode string

@description('Suffix used in the applications data Storage Account name.')
@minLength(6)
@maxLength(6)
param appsDataStorageNameSuffix string
@description('SKU name of the Storage Account.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
param appsDataStorageSkuName string

@description('Suffix used in the name of the Azure SQL Server.')
@minLength(6)
@maxLength(6)
param sqlServerNameSuffix string
@description('SKU type for the Azure SQL Database. Use GeneralPurpose for zone redudant database.')
@allowed([
  'Standard'
  'GeneralPurpose'
])
param sqlDatabaseSkuType string
@description('SKU size for the Azure SQL Database.')
param sqlDatabaseSkuSize int
@description('Minimum capacity of the Azure SQL Database.')
param sqlDatabaseMinCapacity int
@description('Maximum size in GB of the Azure SQL Database.')
param sqlDatabaseMaxSizeGB int
@description('Enable zone redundancy for the Azure SQL Database.')
param sqlDatabaseZoneRedundant bool
@description('Number of replicas for the Azure SQL Database.')
param sqlDatabaseReplicaCount int
@description('Route read-only connections to secondary read-only replicas.')
@allowed([
  'Enabled'
  'Disabled'
])
param sqlDatabaseReadScaleOut string
@description('Storage redundancy used by the backups of the Azure SQL Database.')
param sqlDatabaseBackupRedundancy string
@description('Type of license for Azure SQL Database instance.')
param sqlDatabaseLicenseType string
@description('Collation of the Azure SQL Database instance.')
param sqlDatabaseCollation string

@description('Suffix used in the Container Registry name.')
@minLength(6)
@maxLength(6)
param acrNameSuffix string
@description('Selected tier for the Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string
@description('If zone redundancy Enabled or Disabled for the Container Registry.')
@allowed([
  'Enabled'
  'Disabled'
])
param acrZoneRedundancy string
@description('Retention days of untagged images in the Container Registry.')
param acrUntaggedRetentionDays int
@description('Retention days of soft deleted images in the Container Registry.')
param acrSoftDeleteRetentionDays int

@description('Tier of the AKS Managed Cluster. Use Paid for HA with multiple AZs.')
@allowed([
  'Free'
  'Paid'
])
param aksSkuTier string
@description('Suffix used in the DNS name of the AKS Managed Cluster.')
@minLength(6)
@maxLength(6)
param aksDnsSuffix string
@description('Version of the Kubernetes software used by AKS.')
param aksKubernetesVersion string
@description('Enable auto scaling for AKS system node pool.')
param aksEnableAutoScaling bool
@description('Minimum number of nodes in the AKS system node pool.')
param aksNodePoolMinCount int
@description('Maximum number of nodes in the AKS system node pool.')
param aksNodePoolMaxCount int
@description('VM size of every node in the AKS system node pool.')
param aksNodePoolVmSize string
@description('Enable encryption at AKS nodes.')
param aksEnableEncryptionAtHost bool
@description('Create the AKS Managed Cluster as private cluster.')
param aksEnablePrivateCluster bool
@description('Enable Pod-Managed Identity feature on the AKS Managed Cluster.')
param aksEnablePodManagedIdentities bool
@description('Enable Workload Identity feature on the AKS Managed Cluster.')
param aksEnableWorkloadIdentity bool
@description('Enable AKS Application Gateway Ingress Controller (AGIC) add-on.')
param aksEnableAGICAddon bool
@description('Create custom Route Table for Gateway Subnet managed by AKS (with kubenet network plugin).')
param aksCreateCustomRouteTable bool

// ==================================== Diagnostics options ====================================

@description('Enable diagnostics to store Application Gateway logs and metrics.')
param appGatewayEnableDiagnostics bool
@description('Retention days of the Application Gateway logs. Must be defined if enableDiagnostics is true.')
param appGatewayLogsRetentionDays int

@description('Enable diagnostics to store applications data Storage Account access logs.')
param appsDataStorageEnableDiagnostics bool
@description('Retention days of the applications data Storage Account access logs. Must be defined if enableDiagnostics is true.')
param appsDataStorageLogsRetentionDays int

@description('Enable Auditing feature on Azure SQL Server.')
param sqlDatabaseEnableAuditing bool
@description('Retention days of the Azure SQL Database audit logs. Must be defined if enableAuditing is true.')
param sqlDatabaseAuditLogsRetentionDays int
@description('Enable Advanced Threat Protection on Azure SQL Server.')
param sqlDatabaseEnableThreatProtection bool
@description('Enable Vulnerability Assessments on Azure SQL Server.')
param sqlDatabaseEnableVulnerabilityAssessments bool

@description('Enable diagnostics to store Container Registry audit logs.')
param acrEnableDiagnostics bool
@description('Retention days of the Container Registry audit logs. Must be defined if enableDiagnostics is true.')
param acrLogsRetentionDays int

@description('Enable AKS OMS Agent add-on.')
param aksEnableOMSAgentAddon bool

// ==================================== Resource Locks switches ====================================

@description('Enable Resource Lock on Application Gateway.')
param appGatewayEnableLock bool
@description('Enable Resource Lock on applications data Storage Account.')
param appsDataStorageEnableLock bool
@description('Enable Resource Lock on Azure SQL Server.')
param sqlDatabaseEnableLock bool
@description('Enable Resource Lock on Container Registry.')
param acrEnableLock bool
@description('Enable Resource Lock on AKS Managed Cluster.')
param aksEnableLock bool

// ==================================== PaaS Firewall settings ====================================

@description('Enable public access in the PaaS firewall.')
param appsDataStorageEnablePublicAccess bool
@description('Allow bypass of PaaS firewall rules to Azure Services.')
param appsDataStorageBypassAzureServices bool
@description('List of Subnets allowed to access the Storage Account in the PaaS firewall.')
@metadata({
  vnetName: 'Name of VNet.'
  subnetName: 'Name of the Subnet.'
})
param appsDataStorageAllowedSubnets array
@description('List of IPs or CIDRs allowed to access the Storage Account in the PaaS firewall.')
param appsDataStorageAllowedIPsOrCIDRs array

@description('Enable public access in the PaaS firewall.')
param sqlDatabaseEnablePublicAccess bool
@description('List of Subnets allowed to access the Azure SQL Database in the firewall.')
@metadata({
  vnetName: 'Name of VNet.'
  subnetName: 'Name of the Subnet.'
})
param sqlDatabaseAllowedSubnets array
@description('List of IPs ranges (start and end IP addresss) allowed to access the Azure SQL Server in the firewall.')
@metadata({
  startIPAddress: 'First IP in the IP range.'
  endIPAddress: 'Last IP in the IP range.'
})
param sqlDatabaseAllowedIPRanges array

@description('Enable public access in the PaaS firewall.')
param acrEnablePublicAccess bool
@description('Allow bypass of PaaS firewall rules to Azure Services.')
param acrBypassAzureServices bool
@description('List of IPs or CIDRs allowed to access the Container Registry in the PaaS firewall.')
param acrAllowedIPsOrCIDRs array

@description('Enable public access to the AKS Management Plane.')
param aksEnablePublicAccess bool

// ==================================== Module switches ====================================

@description('Create or update Private Endpoint modules.')
param updatePrivateEndpointModules bool

@description('Create or update Application Gateway module.')
param updateAgwModule bool

@description('Create or update Azure SQL Database module.')
param updateSqlDatabaseModule bool

@description('Create or update AKS related modules.')
param updateAksModules bool

// ==================================== Modules ====================================

module systemUsersModule 'modules/systemUsers.bicep' = {
  name: 'systemUsersModule'
  params: {
  }
}

module systemRgRbacModule 'modules/systemRgRbac.bicep' = {
  name: 'systemRgRbacModule'
  params: {
  }
}

var linkedVNetNamesForPrivateEndpoints = [
  gatewayVNetName
  appsVNetName
  endpointsVNetName
  jumpServersVNetName
  devopsAgentsVNetName
]

var linkedVNetNamesForAksPrivateEndpoint = [
  appsVNetName
  jumpServersVNetName
  devopsAgentsVNetName
]

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
    gatewayVNetName: gatewayVNetName
    gatewaySubnetName: gatewaySubnetName
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

module appsDataStoragePrivateEndpointModule 'modules/privateEndpoint.bicep' = if (updatePrivateEndpointModules) {
  name: 'appsDataStoragePrivateEndpointModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointName: 'PE04'
    vnetName: endpointsVNetName
    subnetName: endpointsSubnetName
    privateIPAddresses: [ appsDataStoragePEPrivateIPAddress ]
    serviceId: appsDataStorageModule.outputs.storageAccountId
    groupId: 'blob'
    linkedVNetNames: linkedVNetNamesForPrivateEndpoints
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
    enableAADAdminUser: sqlDatabaseEnableAADAdminUser
    aadAdminLoginName: sqlDatabaseAADAdminLoginName
    aadAdminPrincipalId: sqlDatabaseAADAdminPrincipalId
    skuType: sqlDatabaseSkuType
    skuSize: sqlDatabaseSkuSize
    minCapacity: sqlDatabaseMinCapacity
    maxSizeGB: sqlDatabaseMaxSizeGB
    zoneRedundant: sqlDatabaseZoneRedundant
    replicaCount: sqlDatabaseReplicaCount
    readScaleOut: sqlDatabaseReadScaleOut
    backupRedundancy: sqlDatabaseBackupRedundancy
    licenseType: sqlDatabaseLicenseType
    collation: sqlDatabaseCollation
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

module sqlDatabasePrivateEndpointModule 'modules/privateEndpoint.bicep' = if (updatePrivateEndpointModules) {
  name: 'sqlDatabasePrivateEndpointModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointName: 'PE01'
    vnetName: endpointsVNetName
    subnetName: endpointsSubnetName
    privateIPAddresses: [ sqlDatabasePEPrivateIPAddress ]
    serviceId: sqlDatabaseModule.outputs.sqlServerId
    groupId: 'sqlServer'
    linkedVNetNames: linkedVNetNamesForPrivateEndpoints
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

module acrPrivateEndpointModule 'modules/privateEndpoint.bicep' = if (updatePrivateEndpointModules) {
  name: 'acrPrivateEndpointModule'
  params: {
    location: location
    env: env
    standardTags: standardTags
    privateEndpointName: 'PE03'
    vnetName: endpointsVNetName
    subnetName: endpointsSubnetName
    privateIPAddresses: acrPEPrivateIPAddresses
    serviceId: acrModule.outputs.registryId
    groupId: 'registry'
    linkedVNetNames: linkedVNetNamesForPrivateEndpoints
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
    vnetName: appsVNetName
    subnetName: appsSubnetName
    enableAutoScaling: aksEnableAutoScaling
    nodePoolMinCount: aksNodePoolMinCount
    nodePoolMaxCount: aksNodePoolMaxCount
    nodePoolVmSize: aksNodePoolVmSize
    enableEncryptionAtHost: aksEnableEncryptionAtHost
    enablePrivateCluster: aksEnablePrivateCluster
    privateDnsZoneLinkedVNetNames: linkedVNetNamesForAksPrivateEndpoint
    enablePodManagedIdentities: aksEnablePodManagedIdentities
    podIdentities: []
    enableWorkloadIdentity: aksEnableWorkloadIdentity
    enableAGICAddon: aksEnableAGICAddon
    appGatewayName: appGatewayModule.outputs.applicationGatewayName
    createCustomRouteTable: aksCreateCustomRouteTable
    enableOMSAgentAddon: aksEnableOMSAgentAddon
    workspaceName: monitoringWorkspaceName
    enableLock: aksEnableLock
    enablePublicAccess: aksEnablePublicAccess
  }
}

module aksRbacModule 'modules/aksRbac.bicep' = {
  name: 'aksRbacModule'
  params: {
    aksClusterId: aksModule.outputs.aksClusterId
    aksKubeletPrincipalId: aksModule.outputs.aksKubeletPrincipalId
    aksAGICPrincipalId: aksModule.outputs.aksAGICPrincipalId
    appGatewayName: appGatewayModule.outputs.applicationGatewayName
  }
}

module aksNodeGroupRbacModule 'modules/aksNodeGroupRbac.bicep' = {
  name: 'aksNodeGroupRbacModule'
  scope: resourceGroup('MC_${resourceGroup().name}_BRS-MEX-USE2-CRECESDX-${env}-KU01_${location}')
  params: {
    aksClusterId: aksModule.outputs.aksClusterId
    aksKubeletPrincipalId: aksModule.outputs.aksKubeletPrincipalId
  }
}
