param flowLogsTargetNSGName string

var targetNSGId = resourceId('Microsoft.Network/networkSecurityGroups', flowLogsTargetNSGName)

output targetNSGId string = targetNSGId
