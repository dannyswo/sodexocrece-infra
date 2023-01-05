/**
 * Module: app-gateway-existing
 * Depends on: N/A
 * Used by: system/main-system
 * Common resources: N/A
 */

 // ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Suffix used in the name of the Application Gateway.')
@minLength(6)
@maxLength(6)
param appGatewayNameSuffix string

// ==================================== Resources ====================================

// ==================================== Application Gateway ====================================

resource appGateway 'Microsoft.Network/applicationGateways@2022-05-01' existing = {
  name: 'azuswa1${appGatewayNameSuffix}'
}

// ==================================== Outputs ====================================

@description('ID of the Application Gateway.')
output applicationGatewayId string = appGateway.id

@description('Name of the Application Gateway.')
output applicationGatewayName string = appGateway.name
