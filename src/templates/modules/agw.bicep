@description('Azure region.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

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

@description('Create frontend public IP for the Application Gateway.')
param enablePublicIP bool

@description('Name of the Gateway VNet where Application Gateway is deployed.')
param gatewayVNetName string

@description('Name of the Gateway Subnet where Application Gateway is deployed.')
param gatewaySubnetName string

@description('Private IP address of the Application Gateway. Must be defined if SKU tier is WAF_v2.')
param appGatewayPrivateIPAddress string

@description('Minimum capacity for auto scaling of Application Gateway.')
param autoScaleMinCapacity int

@description('Maximum capacity for auto scaling of Application Gateway.')
param autoScaleMaxCapacity int

@description('Enable a Listener on port 80.')
param enableHttpPort bool

@description('Enable Listener on port 443 and setup the public SSL certificate.')
param enableHttpsPort bool

@description('ID of the public SSL certificate stored in Key Vault.')
param publicCertificateId string

@description('Standards tags applied to all resources.')
param standardTags object = resourceGroup().tags

var appGatewayName = 'azmxwa1${appGatewayNameSuffix}'

var zones = [ '1', '2', '3' ]

var gatewaySubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', gatewayVNetName, gatewaySubnetName)

var frontendPort80 = {
  name: '${appGatewayName}-Port-80'
  properties: {
    port: 80
  }
}

var frontendPort443 = {
  name: '${appGatewayName}-Port-443'
  properties: {
    port: 443
  }
}

var frontendPorts = (enableHttpPort && enableHttpsPort) ? [
  frontendPort80
  frontendPort443
] : (enableHttpPort) ? [
  frontendPort80
] : (enableHttpsPort) ? [
  frontendPort443
] : []

var httpListener80 = {
  name: '${appGatewayName}-Listener-80'
  properties: {
    protocol: 'Http'
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, '${appGatewayName}-FrontIP-443')
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, '${appGatewayName}-Port-80')
    }
  }
}

var httpListener443 = {
  name: '${appGatewayName}-Listener-443'
  properties: {
    protocol: 'Https'
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, '${appGatewayName}-FrontIP-443')
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, '${appGatewayName}-Port-443')
    }
    sslCertificate: (enableHttpsPort) ? {
      id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, '${appGatewayName}-SSLCertificate-Public')
    } : null
    sslProfile: {
      id: resourceId('Microsoft.Network/applicationGateways/sslProfiles', appGatewayName, '${appGatewayName}-SSLProfile')
    }
    firewallPolicy: {
      id: wafPolicies.id
    }
  }
}

var httpListeners = (enableHttpPort && enableHttpsPort) ? [
  httpListener80
  httpListener443
] : (enableHttpPort) ? [
  httpListener80
] : (enableHttpsPort) ? [
  httpListener443
] : []

resource appGateway 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: appGatewayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  zones: zones
  properties: {
    sku: {
      tier: appGatewaySkuTier
      name: appGatewaySkuName
      //capacity: appGatewaySkuCapacity
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
          privateIPAddress: appGatewayPrivateIPAddress
          publicIPAddress: (enablePublicIP) ? {
            id: publicIpAddress.id
          } : null
        }
      }
    ]
    frontendPorts: frontendPorts
    httpListeners: httpListeners
    backendAddressPools: [
      {
        name: '${appGatewayName}-Backend0'
      }
    ]
    sslCertificates: (enableHttpsPort) ? [
      {
        name: '${appGatewayName}-SSLCertificate-Public'
        properties: {
          keyVaultSecretId: publicCertificateId
        }
      }
    ] : []
    sslProfiles: (enableHttpsPort) ? [
      {
        name: '${appGatewayName}-SSLProfile'
        properties: {
          sslPolicy: {
            minProtocolVersion: 'TLSv1_2'
            cipherSuites: [
              'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
              'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
              'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
              'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
              'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
            ]
            disabledSslProtocols: [
              'TLSv1_0'
              'TLSv1_1'
            ]
          }
        }
      }
    ] : []
  }
  tags: standardTags
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = if (enablePublicIP) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-PI01'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    deleteOption: 'Delete'
  }
  tags: standardTags
}

resource wafPolicies 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-WP01'
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

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD01'
  location: location
  tags: standardTags
}

@description('ID of the Role Definition: Key Vault Certificates Officer | Perform any action on the certificates of a key vault.')
var roleDefinitionId = 'a4417e6f-fecd-4de8-b567-7b0420556985'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AD02'
  scope: resourceGroup()
  properties: {
    description: 'Access public certificate in the Key Vault from Application Gateway \'${appGatewayName}\''
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

resource appGatewayLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AL02'
  scope: appGateway
  properties: {
    level: 'CanNotDelete'
    notes: 'Application Gateway should not be deleted.'
  }
}

@description('ID of the Application Gateway.')
output applicationGatewayId string = appGateway.id

@description('Name of the Application Gateway.')
output applicationGatewayName string = appGateway.name

@description('ID of the Managed Identity of Application Gateway.')
output appGatewayManagedIdentityId string = managedIdentity.id
