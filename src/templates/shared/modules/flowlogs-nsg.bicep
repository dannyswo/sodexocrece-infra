/**
 * Module: flowlogs-nsg
 * Depends on: network
 * Used by: shared/main-shared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

param flowLogsTargetNSGName string

// ==================================== Resources ====================================

var targetNSGId = resourceId('Microsoft.Network/networkSecurityGroups', flowLogsTargetNSGName)

// ==================================== Outputs ====================================

output flowLogsTargetNSGId string = targetNSGId
