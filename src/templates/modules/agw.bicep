@description('Azure region to deploy the AKS Managed Cluster.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param environment string

@description('Suffix used in the name of the Application Gateway.')
@minLength(6)
@maxLength(6)
param appGatewayNameSuffix string

@description('SKU tier of the Application Gateway.')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param appGatewaySkuTier string

@description('SKU name of the Application Gateway.')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param appGatewaySkuName string

@description('SKU capacity of the Application Gateway.')
param appGatewaySkuCapacity int

@description('Create frontend public IP for the Application Gateway.')
param enablePublicIp bool

@description('ID of the Gateway Subnet where Application Gateway is deployed.')
param gatewaySubnetId string

@description('Minimum capacity for auto scaling of Application Gateway.')
param autoScaleMinCapacity int

@description('Maximum capacity for auto scaling of Application Gateway.')
param autoScaleMaxCapacity int

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var appGatewayName = 'azmxwa1${appGatewayNameSuffix}'

var zones = [ '1', '2', '3' ]

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: appGatewayName
  location: location
  /*
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appGatewayManagedIdentity.id}'
    }
  }
  */
  zones: zones
  properties: {
    sku: {
      tier: appGatewaySkuTier
      name: appGatewaySkuName
      capacity: appGatewaySkuCapacity
    }
    autoscaleConfiguration: {
      minCapacity: autoScaleMinCapacity
      maxCapacity: autoScaleMaxCapacity
    }
    enableHttp2: false
    gatewayIPConfigurations: [
      {
        name: '${appGatewayName}-GatewayIPConfig'
        properties: {
          subnet: {
            id: gatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: '${appGatewayName}-FrontIP-443'
        properties: {
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: '${appGatewayName}-Port-80'
        properties: {
          port: 80
        }
      }
      {
        name: '${appGatewayName}-Port-443'
        properties: {
          port: 443
        }
      }
    ]
    httpListeners: [
      {
        name: '${appGatewayName}-Listener-80'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, '${appGatewayName}-FrontIP-443')
          }
          protocol: 'Http'
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, '${appGatewayName}-Port-80')
          }
        }
      }
      {
        name: '${appGatewayName}-Listener-443'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, '${appGatewayName}-FrontIP-443')
          }
          protocol: 'Http'
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, '${appGatewayName}-Port-443')
          }
        }
      }
    ]
    sslCertificates: [
    ]
    firewallPolicy: {
      id: wafPolicies.id
    }
  }
  tags: standardTags
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = if (enablePublicIp) {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-PI01'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Global'
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    deleteOption: 'Delete'
  }
  tags: standardTags
}

resource wafPolicies 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${environment}-WP01'
  location: location
  properties: {
    policySettings: {
      state: 'Enabled'
      mode: 'Detection'
      requestBodyCheck: true
      fileUploadLimitInMb: 100
      maxRequestBodySizeInKb: 128
    }
    managedRules: {
      exclusions: []
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          ruleGroupOverrides: null
        }
      ]
    }
    customRules: []
  }
  tags: standardTags
}

output applicationGatewayId string = applicationGateway.id
