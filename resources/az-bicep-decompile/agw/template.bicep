param location string
param applicationGatewayName string
param tier string
param skuSize string
param capacity int = 2
param subnetName string
param zones array
param wafPolicyName string
param publicIpAddressName string
param sku string
param allocationMethod string
param publicIpZones array
param privateIpAddress string
param autoScaleMaxCapacity int

var vnetId = '/subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourceGroups/sodexocrecer-rg01/providers/Microsoft.Network/virtualNetworks/sodexocrecer-vnet01'
var publicIPRef = publicIpAddress.id
var subnetRef = '${vnetId}/subnets/${subnetName}'
var applicationGatewayId = applicationGateway.id

resource applicationGateway 'Microsoft.Network/applicationGateways@2021-08-01' = {
  name: applicationGatewayName
  location: location
  zones: zones
  tags: {
    Organization: 'Sodexo'
    System: 'SodexoCrecer'
    Environment: 'SWODEV'
  }
  properties: {
    sku: {
      name: skuSize
      tier: tier
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: publicIPRef
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIp'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAddress: privateIpAddress
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'sodexocrecer-agw-backend01'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'sodexocrecer-agw-ruleset01'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 15
          connectionDraining: {
            drainTimeoutInSec: 60
            enabled: true
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'sodexocrecer-agw-listener-80'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayId}/frontendIPConfigurations/appGwPrivateFrontendIp'
          }
          frontendPort: {
            id: '${applicationGatewayId}/frontendPorts/port_80'
          }
          protocol: 'Http'
          sslCertificate: null
          hostName: 'apps.sdxcloud.com'
          requireServerNameIndication: false
        }
      }
    ]
    listeners: []
    requestRoutingRules: [
      {
        name: 'sodexocrecer-agw-rule01'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayId}/httpListeners/sodexocrecer-agw-listener-80'
          }
          priority: 10
          backendAddressPool: {
            id: '${applicationGatewayId}/backendAddressPools/sodexocrecer-agw-backend01'
          }
          backendHttpSettings: {
            id: '${applicationGatewayId}/backendHttpSettingsCollection/sodexocrecer-agw-ruleset01'
          }
        }
      }
    ]
    routingRules: []
    enableHttp2: false
    sslCertificates: []
    probes: []
    autoscaleConfiguration: {
      minCapacity: capacity
      maxCapacity: autoScaleMaxCapacity
    }
    firewallPolicy: {
      id: '/subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourceGroups/sodexocrecer-rg01/providers/Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/sodexocrecer-wafpol01'
    }
  }
  dependsOn: [
    'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/${wafPolicyName}'

  ]
}

resource sodexocrecer_wafpol01 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' = {
  name: 'sodexocrecer-wafpol01'
  location: location
  tags: {
  }
  properties: {
    policySettings: {
      mode: 'Detection'
      state: 'Enabled'
      fileUploadLimitInMb: 100
      requestBodyCheck: true
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
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: sku
  }
  zones: publicIpZones
  properties: {
    publicIPAllocationMethod: allocationMethod
  }
}