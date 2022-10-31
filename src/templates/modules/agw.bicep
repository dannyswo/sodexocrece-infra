param location string
param environment string = 'DEV'
param tier string

param skuSize string
param capacity int = 2
param subnetName string
param zones array = []
param publicIpAddressName string
param allocationMethod string
param publicIpZones array
param privateIpAddress string
param autoScaleMaxCapacity int
param randomString string
param randomNumber int

var businessLine = 'BRS'
var businessRegion = 'LATAM'
var projectName = 'CRECESDX'
var privateAsset = '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}'
var cloudProvider = 'az'
var cloudRegion = 'mx'
var cloudService = 'agw'
var vnetId = '/subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourceGroups/sodexocrecer-rg01/providers/Microsoft.Network/virtualNetworks/sodexocrecer-vnet01'
var publicIPRef = publicIpAddress.id
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: '${cloudProvider}${cloudRegion}${cloudService}1${randomString}${randomNumber}'
  location: location
  // zones: zones
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
        name: '${privateAsset}-backend01'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: '${privateAsset}-ruleset01'
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
        name: '${privateAsset}-listener80'
        properties: {
          frontendIPConfiguration: {
            id: 'test/frontendIPConfigurations/appGwPrivateFrontendIp'
          }
          frontendPort: {
            id: 'test/frontendPorts/port_80'
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
        name: '${privateAsset}-rule01'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: 'test/httpListeners/sodexocrecer-agw-listener-80'
          }
          priority: 10
          backendAddressPool: {
            id: 'test/backendAddressPools/sodexocrecer-agw-backend01'
          }
          backendHttpSettings: {
            id: 'test/backendHttpSettingsCollection/sodexocrecer-agw-ruleset01'
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
    sodexocrecer_wafpol01
  ]
}

resource sodexocrecer_wafpol01 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-05-01' = {
  name: '${privateAsset}-wafpol01'
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

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: publicIpZones
  properties: {
    publicIPAllocationMethod: allocationMethod
  }
}
