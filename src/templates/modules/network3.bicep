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

@description('Name of the Gateway VNet.')
param gatewayVNetName string

@description('Name of the Gateway Subnet.')
param gatewaySubnetName string

@description('Name of the Applications VNet.')
param appsVNetName string

@description('Standard name of the Applications Subnet.')
param appsSubnetName string

@description('Enable custom Route Table for AKS attached to Gateway and Apps VNet.')
param enableCustomRouteTable bool

@description('Enable Key Vault Service Endpoint on Gateway Subnet.')
param enableKeyVaultServiceEndpoint bool

@description('Enable Storage Account Service Endpoint on Gateway and Apps Subnet.')
param enableStorageAccountServiceEndpoint bool

@description('ID of the Service Endpoint Policies to access Key Vault.')
param keyVaultServiceEndpointPoliciesId string

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource definitions ====================================

// ==================================== VNets and Subnets ====================================

var serviceEndpoints = {
  keyVault: {
    locations: [ location ]
    service: 'Microsoft.KeyVault'
  }
  storageAccount: {
    locations: [ location ]
    service: 'Microsoft.Storage'
  }
}

var allSubnetsServiceEndpoints0 = (enableKeyVaultServiceEndpoint) ? [ serviceEndpoints.keyVault ] : []
var allSubnetsServiceEndpoints = (enableStorageAccountServiceEndpoint) ? concat(allSubnetsServiceEndpoints0, [ serviceEndpoints.storageAccount ]) : allSubnetsServiceEndpoints0

var serviceEndpointPolicies = {
  keyVault: {
    id: keyVaultServiceEndpointPoliciesId
  }
  monitoringDataStorage: {
    id: null
  }
}

var allSubnetsServiceEndpointPolicies0 = (enableKeyVaultServiceEndpoint) ? [ serviceEndpointPolicies.keyVault ] : []
var allSubnetsServiceEndpointPolicies = (enableStorageAccountServiceEndpoint) ? concat(allSubnetsServiceEndpoints0, [ serviceEndpointPolicies.monitoringDataStorage ]) : allSubnetsServiceEndpointPolicies0

resource gatewayVNet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: gatewayVNetName
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: gatewaySubnetName
  parent: gatewayVNet
  properties: {
    routeTable: (enableCustomRouteTable) ? {
      id: aksCustomRouteTable.id
    } : null
    serviceEndpoints: allSubnetsServiceEndpoints
    serviceEndpointPolicies: allSubnetsServiceEndpointPolicies
  }
}

resource appsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: appsVNetName
}

resource appsSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: appsSubnetName
  parent: appsVNet
  properties: {
    routeTable: (enableCustomRouteTable) ? {
      id: aksCustomRouteTable.id
    } : null
    serviceEndpoints: allSubnetsServiceEndpoints
    serviceEndpointPolicies: allSubnetsServiceEndpointPolicies
  }
}

// ==================================== Route Tables ====================================

resource aksCustomRouteTable 'Microsoft.Network/routeTables@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-UD01'
  location: location
  properties: {
    routes: []
  }
  tags: standardTags
}
