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

resource targetNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' existing = {
  name: flowLogsTargetNSGName
}

// ==================================== Outputs ====================================

output flowLogsTargetNSGId string = targetNSG.id
