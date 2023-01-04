/**
 * Template: landing-zone/main-landing-zone
 * Modules:
 * - IAM: N/A
 * - Network: network-module
 * - Security: N/A
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

// ==================================== Network settings ====================================

@description('Create VNets, Subnets and NSGs resources.')
param createNetwork bool

@description('Create custom Route Table for Gateway Subnet managed by AKS (with kubenet network plugin).')
param createCustomRouteTable bool

@description('Create VM in the Jump Servers Subnet.')
param createJumpServer bool

@description('Username of the Jump Server admin')
@secure()
param jumpServerAdminUsername string

@description('Password of the Jump Server admin')
@secure()
param jumpServerAdminPassword string

@description('Create Private DNS Zones for all Private Endpoints.')
param createPrivateDnsZones bool

// ==================================== Modules ====================================

var standardTagsWithDatadogTags = union(standardTags, {
    dd_organization: 'MX'
    countries: 'mx'
    Maintainer: 'SoftwareONE'
  })

module networkModule 'modules/network.bicep' = if (createNetwork) {
  name: 'network-module'
  params: {
    location: location
    env: env
    standardTags: standardTagsWithDatadogTags
    frontendVNetNameSuffix: 'VN01'
    frontendVNetAddressPrefix: '10.169.72.0/21'
    gatewaySubnetNameSuffix: 'SN01'
    gatewaySubnetAddressPrefix: '10.169.72.64/28'
    aksVNetNameSuffix: 'VN02'
    aksVNetAddressPrefix: '10.169.92.0/22'
    aksSubnetNameSuffix: 'SN02'
    aksSubnetAddressPrefix: '10.169.93.0/25'
    endpointsVNetNameSuffix: 'VN03'
    endpointsVNetAddressPrefix: '10.169.88.0/23'
    endpointsSubnetNameSuffix: 'SN03'
    endpointsSubnetAddressPrefix: '10.169.88.64/26'
    jumpServersVNetNameSuffix: 'VN04'
    jumpServersVNetAddressPrefix: '10.169.32.0/24'
    jumpServersSubnetNameSuffix: 'SN04'
    jumpServersSubnetAddressPrefix: '10.169.32.32/27'
    devopsAgentsVNetNameSuffix: 'VN05'
    devopsAgentsVNetAddressPrefix: '10.169.90.0/24'
    devopsAgentsSubnetNameSuffix: 'SN05'
    devopsAgentsSubnetAddressPrefix: '10.169.90.0/27'
    createCustomRouteTable: createCustomRouteTable
    enableKeyVaultServiceEndpoint: true
    enableStorageAccountServiceEndpoint: true
    enableSqlDatabaseServiceEndpoint: false
    enableContainerRegistryServiceEndpoint: false
  }
}

module jumpServer1Module 'modules/jump-server.bicep' = if (createNetwork && createJumpServer) {
  name: 'jump-server1-module'
  params: {
    location: location
    env: env
    standardTags: standardTagsWithDatadogTags
    adminUsername: jumpServerAdminUsername
    adminPassword: jumpServerAdminPassword
    jumpServersVNetName: networkModule.outputs.vnets[3].name
    jumpServersSubnetName: networkModule.outputs.subnets[3].name
    jumpServersNSGName: networkModule.outputs.networkSecurityGroups[3].name
    jumpServerNameSuffix: 'VM01'
    jumpServerComputerNameSuffix: 'SOOJMP2P'
  }
}

var linkedVNetIdsForPrivateEndpoints = [
  networkModule.outputs.vnets[0].id
  networkModule.outputs.vnets[1].id
  networkModule.outputs.vnets[2].id
  networkModule.outputs.vnets[3].id
  networkModule.outputs.vnets[4].id
]

var linkedVNetIdsForAksPrivateEndpoint = [
  networkModule.outputs.vnets[1].id
  networkModule.outputs.vnets[3].id
  networkModule.outputs.vnets[4].id
]

module privateDnsZoneKeyVaultModule 'modules/private-dns-zone.bicep' = if (createPrivateDnsZones) {
  name: 'private-dns-zone-keyvault-module'
  params: {
    location: location
    standardTags: standardTagsWithDatadogTags
    namespace: 'vault'
    linkedVNetIds: linkedVNetIdsForPrivateEndpoints
  }
}

module privateDnsZoneStorageAccountBlobModule 'modules/private-dns-zone.bicep' = if (createPrivateDnsZones) {
  name: 'private-dns-zone-blob-module'
  params: {
    location: location
    standardTags: standardTagsWithDatadogTags
    namespace: 'blob'
    linkedVNetIds: linkedVNetIdsForPrivateEndpoints
  }
}

module privateDnsZoneSqlDatabaseModule 'modules/private-dns-zone.bicep' = if (createPrivateDnsZones) {
  name: 'private-dns-zone-sqlserver-module'
  params: {
    location: location
    standardTags: standardTagsWithDatadogTags
    namespace: 'sqlServer'
    linkedVNetIds: linkedVNetIdsForPrivateEndpoints
  }
}

module privateDnsZoneContainerRegistryModule 'modules/private-dns-zone.bicep' = if (createPrivateDnsZones) {
  name: 'private-dns-zone-registry-module'
  params: {
    location: location
    standardTags: standardTagsWithDatadogTags
    namespace: 'registry'
    linkedVNetIds: linkedVNetIdsForPrivateEndpoints
  }
}

module privateDnsZoneAksModule 'modules/private-dns-zone.bicep' = if (createPrivateDnsZones) {
  name: 'private-dns-zone-aks-module'
  params: {
    location: location
    standardTags: standardTagsWithDatadogTags
    namespace: 'aks'
    linkedVNetIds: linkedVNetIdsForAksPrivateEndpoint
  }
}
