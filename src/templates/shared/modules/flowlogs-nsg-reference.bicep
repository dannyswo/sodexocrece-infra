/**
 * Module: flowlogs-nsg-reference
 * Depends on: network
 * Used by: shared/main-shared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('ID of the Prod / Non Prod Subscription.')
param prodSubscriptionId string

@description('Name of the Resource Group for network resources in Prod / Non Prod Subscription.')
param prodNetworkResourceGroupName string

@description('Name of the NSG used as target by the Flow Logs resource.')
param flowLogsTargetNSGName string

// ==================================== Resources ====================================

var targetNSGId = resourceId(prodSubscriptionId, prodNetworkResourceGroupName, 'Microsoft.Network/networkSecurityGroups', flowLogsTargetNSGName)

// ==================================== Outputs ====================================

@description('ID of the NSG used as target by the Flow Logs resource.')
output flowLogsTargetNSGId string = targetNSGId
