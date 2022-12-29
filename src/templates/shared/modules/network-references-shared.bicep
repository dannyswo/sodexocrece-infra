/**
 * Module: network-references-shared
 * Depends on: network
 * Used by: system/main-shared
 * Resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

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

@description('Name of the Jump Servers VNet.')
param jumpServersVNetName string

@description('Name of the Jump Servers Subnet.')
param jumpServersSubnetName string

@description('Name of the DevOps Agents VNet.')
param devopsAgentsVNetName string

@description('Name of the DevOps Agents Subnet.')
param devopsAgentsSubnetName string

// ==================================== Resources ====================================

// ==================================== Existing VNets ====================================

var frontendVNetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', frontendVNetName)

var aksVNetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', aksVNetName)

var endpointsVNetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', endpointsVNetName)

var jumpServersVNetId = resourceId(sharedServicesSubscriptionId, prdSharedServicesNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', jumpServersVNetName)

var devopsAgentsVNetId = resourceId(sharedServicesSubscriptionId, devSharedServicesNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', devopsAgentsVNetName)

// ==================================== Existing Subnets ====================================

var gatewaySubnetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', frontendVNetName, gatewaySubnetName)

var aksSubnetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', aksVNetName, aksSubnetName)

var endpointsSubnetId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', endpointsVNetName, endpointsSubnetName)

var jumpServersSubnetId = resourceId(sharedServicesSubscriptionId, prdSharedServicesNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', jumpServersVNetName, jumpServersSubnetName)

var devopsAgentsSubnetId = resourceId(sharedServicesSubscriptionId, devSharedServicesNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', devopsAgentsVNetName, devopsAgentsSubnetName)

// ==================================== Existing Private DNS Zones ====================================

var keyVaultPrivateDnsZoneId = resourceId(tier0SubscriptionId, globalDnsResourceGroupName, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.azure.net')

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

@description('ID of the Jump Servers VNet.')
output jumpServersVNetId string = jumpServersVNetId

@description('ID of the Jump Servers Subnet.')
output jumpServersSubnetId string = jumpServersSubnetId

@description('ID of the DevOps Agents VNet.')
output devopsAgentsVNetId string = devopsAgentsVNetId

@description('ID of the DevOps Agents Subnet.')
output devopsAgentsSubnetId string = devopsAgentsSubnetId

@description('ID of the Private DNS Zone for private Key Vaults.')
output keyVaultPrivateDnsZoneId string = keyVaultPrivateDnsZoneId
