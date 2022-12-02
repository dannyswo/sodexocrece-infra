/**
 * Module: shared-network-references
 * Depends on: network
 * Used by: system/main-shared
 * Resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the Apps Shared 03 VNet.')
param appsShared3VNetName string

@description('Name of the AKS VNet.')
param aksVNetName string

@description('Name of the Private Endpoints VNet.')
param endpointsVNetName string

@description('Name of the Private Endpoints Subnet.')
param endpointsSubnetName string

@description('Name of the Apps Shared 02 VNet.')
param appsShared2VNetName string

@description('Name of the Jump Servers Subnet.')
param jumpServersSubnetName string

@description('Name of the DevOps Agents Subnet.')
param devopsAgentsSubnetName string

// ==================================== Resources ====================================

// ==================================== Existing VNets ====================================

resource appsShared3VNet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: appsShared3VNetName
}

resource aksVNet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: aksVNetName
}

resource endpointsVNet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: endpointsVNetName
}

resource appsShared2VNet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: appsShared2VNetName
}

// ==================================== Existing Subnets ====================================

resource endpointsSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: endpointsSubnetName
  parent: endpointsVNet
}

resource jumpServersSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: jumpServersSubnetName
  parent: appsShared2VNet
}

resource devopsAgentsSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: devopsAgentsSubnetName
  parent: appsShared2VNet
}

// ==================================== Outputs ====================================

@description('ID of the Apps Shared 03 VNet.')
output appsShared3VNetId string = appsShared3VNet.id

@description('ID of the AKS VNet.')
output aksVNetId string = aksVNet.id

@description('ID of the Private Endpoints VNet.')
output endpointsVNetId string = endpointsVNet.id

@description('ID of the Private Endpoints Subnet.')
output endpointsSubnetId string = endpointsSubnet.id

@description('ID of the Apps Shared 02 VNet.')
output appsShared2VNetId string = appsShared2VNet.id

@description('ID of the Jump Servers Subnet.')
output jumpServersSubnetId string = jumpServersSubnet.id

@description('ID of the DevOps Agents Subnet.')
output devopsAgentsSubnetId string = devopsAgentsSubnet.id
