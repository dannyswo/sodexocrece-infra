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

// ==================================== Modules ====================================

module networkModule 'modules/network.bicep' = if (createNetwork) {
  name: 'network-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
    frontendVNetNameSuffix: 'VN01'
    frontendVNetAddressPrefix: '10.169.90.0/24'
    gatewaySubnetNameSuffix: 'SN01'
    gatewaySubnetAddressPrefix: '10.169.90.128/25'
    aksVNetNameSuffix: 'VN02'
    aksVNetAddressPrefix: '10.169.72.0/21'
    aksSubnetNameSuffix: 'SN02'
    aksSubnetAddressPrefix: '10.169.72.0/25'
    endpointsVNetNameSuffix: 'VN03'
    endpointsVNetAddressPrefix: '10.169.88.0/23'
    endpointsSubnetNameSuffix: 'SN03'
    endpointsSubnetAddressPrefix: '10.169.88.64/26'
    appsShared2VNetNameSuffix: 'VN04'
    appsShared2VNetAddressPrefix: '10.169.50.0/24'
    jumpServersSubnetNameSuffix: 'SN04'
    jumpServersSubnetAddressPrefix: '10.169.50.64/26'
    devopsAgentsSubnetNameSuffix: 'SN05'
    devopsAgentsSubnetAddressPrefix: '10.169.50.128/26'
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
    standardTags: standardTags
    adminUsername: jumpServerAdminUsername
    adminPassword: jumpServerAdminPassword
    jumpServersVNetName: networkModule.outputs.vnets[3].name
    jumpServersSubnetName: networkModule.outputs.subnets[3].name
    jumpServersNSGName: networkModule.outputs.networkSecurityGroups[3].name
    jumpServerNameSuffix: 'VM01'
    jumpServerComputerNameSuffix: '2P'
  }
}

module networkAttachmentsModule 'modules/network-attachments.bicep' = if (!createNetwork) {
  name: 'network-attachments-module'
  params: {
    location: location
    env: env
    standardTags: standardTags
    // gatewaySubnetId: gatewaySubnetId
    // aksSubnetId: aksSubnetId
    // endpointsSubnetId: endpointsSubnetId
    // jumpServersSubnetId: jumpServersSubnetId
    // devopsAgentsSubnetId: devopsAgentsSubnetId
    // enableCustomRouteTable: enableCustomRouteTable
    // enableKeyVaultServiceEndpoint: enableKeyVaultServiceEndpoint
    // enableStorageAccountServiceEndpoint: enableStorageAccountServiceEndpoint
    // enableSqlDatabaseServiceEndpoint: enableSqlDatabaseServiceEndpoint
    // enableContainerRegistryServiceEndpoint: enableContainerRegistryServiceEndpoint
  }
}
