/**
 * Module: flowLogsNsg
 * Depends on: network1 (optional)
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

param flowLogsTargetNSGName string

// ==================================== Resources ====================================

var targetNSGId = resourceId('Microsoft.Network/networkSecurityGroups', flowLogsTargetNSGName)

// ==================================== Outputs ====================================

output flowLogsTargetNSGId string = targetNSGId