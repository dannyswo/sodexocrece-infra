/**
 * Module: network-references-system
 * Depends on: network
 * Used by: system/main-system
 * Resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('ID of the BRS Shared Services Subscription.')
param brsSubscriptionId string

@description('Name of the Resource Group for network resources in BRS Shared Services Subscription.')
param brsNetworkResourceGroupName string

@description('ID of the Prod / Non Prod Subscription.')
param prodSubscriptionId string

@description('Name of the Resource Group for network resources in Prod / Non Prod Subscription.')
param prodNetworkResourceGroupName string

@description('Name of the Frontend VNet.')
param frontendVNetName string

@description('Name of the Gateway Subnet.')
param gatewaySubnetName string

@description('Name of the AKS VNet.')
param aksVNetName string

@description('Name of the AKS Subnet.')
param aksSubnetName string

@description('Name of the Private Endpoints VNet.')
param endpointsVNetName string

@description('Name of the Private Endpoints Subnet.')
param endpointsSubnetName string

@description('Name of the Apps Shared 02 VNet.')
param appsShared2VNetName string

// ==================================== Resources ====================================

// ==================================== Existing VNets ====================================

var frontendVNetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', frontendVNetName)

var aksVNetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', aksVNetName)

var endpointsVNetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', endpointsVNetName)

var appsShared2VNetId = resourceId(brsSubscriptionId, brsNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', appsShared2VNetName)

// ==================================== Existing Subnets ====================================

var gatewaySubnetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', frontendVNetName, gatewaySubnetName)

var aksSubnetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', aksVNetName, aksSubnetName)

var endpointsSubnetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', endpointsVNetName, endpointsSubnetName)

// ==================================== Outputs ====================================

@description('ID of the Frontend VNet.')
output frontendVNetId string = frontendVNetId

@description('ID of the Gateway Subnet.')
output gatewaySubnetId string = gatewaySubnetId

@description('ID of the AKS VNet.')
output aksVNetId string = aksVNetId

@description('ID of the AKS Subnet.')
output aksSubnetId string = aksSubnetId

@description('ID of the Private Endpoints VNet.')
output endpointsVNetId string = endpointsVNetId

@description('ID of the Private Endpoints Subnet.')
output endpointsSubnetId string = endpointsSubnetId

@description('ID of the Apps Shared 02 VNet.')
output appsShared2VNetId string = appsShared2VNetId
