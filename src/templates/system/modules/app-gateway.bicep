/**
 * Module: app-gateway
 * Depends on: managed-identities, keyvault, network (optional), monitoring-loganalytics-workspace
 * Used by: system/main-system
 * Common resources: RL05, MM05
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

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

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@description('Name of the Managed Identity used by Application Gateway.')
param managedIdentityName string

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

@description('ID of the Gateway Subnet where Application Gateway is deployed.')
param gatewaySubnetId string

@description('Frontend private IP address of Application Gateway.')
param frontendPrivateIPAddress string

@description('Configure HTTP Listeners to receive traffic on public frontend IP. Otherwise, use private frontend IP.')
param enablePublicFrontendIP bool

@description('Minimum capacity for auto scaling of Application Gateway.')
param autoScaleMinCapacity int

@description('Maximum capacity for auto scaling of Application Gateway.')
param autoScaleMaxCapacity int

@description('Enable a Listener on port 80.')
param enableHttpPort bool

@description('Enable Listener on port 443 and setup the public SSL certificate.')
param enableHttpsPort bool

@description('Name of the Key Vault where Certificates used by the Application Gateway are stored.')
param keyVaultName string

@description('Name of the public / frontend SSL certificate stored in Key Vault.')
param frontendCertificateName string

@description('Name of the private / backend SSL certificate stored in Key Vault.')
param backendCertificateName string

@description('Application Gateway WAF Policies mode.')
@allowed([
  'Detection'
  'Prevention'
])
param wafPoliciesMode string

// ==================================== Diagnostics options ====================================

@description('Enable diagnostics to store Application Gateway logs and metrics.')
param enableDiagnostics bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Application Gateway. Must be defined if enableDiagnostics is true.')
param diagnosticsWorkspaceName string

@description('Retention days of the Application Gateway logs. Must be defined if enableDiagnostics is true.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on Application Gateway.')
param enableLock bool

// ==================================== Resources ====================================

// ==================================== Application Gateway ====================================

var appGatewayName = 'azmxwa1${appGatewayNameSuffix}'

var zones = [ '1', '2', '3' ]

var keyVaultSecretsEndpointUri = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/secrets'

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
        name: '${appGatewayName}-FrontIP-Public'
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
      {
        name: '${appGatewayName}-FrontIP-Private'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: frontendPrivateIPAddress
          subnet: {
            id: gatewaySubnetId
          }
        }
      }
    ]
    frontendPorts: frontendPortsList
    httpListeners: httpListenersList
    backendAddressPools: [
      {
        name: '${appGatewayName}-BackendPool-Dummy'
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: '${appGatewayName}-BackendHTTPSettings-Dummy'
        properties: {
          port: 80
        }
      }
    ]
    requestRoutingRules: [
      {
        name: '${appGatewayName}-RoutingRule-Dummy'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, dummyRoutingRuleListenerName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, '${appGatewayName}-BackendHTTPSettings-Dummy')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, '${appGatewayName}-BackendPool-Dummy')
          }
          priority: 10
        }
      }
    ]
    sslCertificates: (enableHttpsPort) ? [
      {
        name: '${appGatewayName}-SSLCertificate-Frontend'
        properties: {
          keyVaultSecretId: '${keyVaultSecretsEndpointUri}/${frontendCertificateName}'
        }
      }
    ] : []
    trustedRootCertificates: (enableHttpsPort) ? [
      {
        name: '${appGatewayName}-TrustedRootCertificate-Backend'
        properties: {
          keyVaultSecretId: '${keyVaultSecretsEndpointUri}/${backendCertificateName}'
        }
      }
    ] : []
    sslProfiles: (enableHttpsPort) ? [
      {
        name: '${appGatewayName}-SSLProfile-Sodexo'
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
            policyType: 'Custom'
          }
        }
      }
    ] : []
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
      policyType: 'Custom'
    }
    firewallPolicy: {
      id: wafPolicies.id
    }
  }
  tags: standardTags
}

// ==================================== Frontend Ports, HTTP Listeners and Routing Rules ====================================

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

var frontendPortsList0 = (enableHttpPort) ? [ frontendPort80 ] : []
var frontendPortsList = (enableHttpsPort) ? concat(frontendPortsList0, [ frontendPort443 ]) : frontendPortsList0

var publicOrPrivateFrontendIPName = (enablePublicFrontendIP) ? '${appGatewayName}-FrontIP-Public' : '${appGatewayName}-FrontIP-Private'

var httpListener80 = (enableHttpPort) ? {
  name: '${appGatewayName}-Listener-80'
  properties: {
    protocol: 'Http'
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, publicOrPrivateFrontendIPName)
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, '${appGatewayName}-Port-80')
    }
  }
} : {}

var httpListener443 = (enableHttpsPort) ? {
  name: '${appGatewayName}-Listener-443'
  properties: {
    protocol: 'Https'
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, publicOrPrivateFrontendIPName)
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, '${appGatewayName}-Port-443')
    }
    sslCertificate: {
      id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, '${appGatewayName}-SSLCertificate-Frontend')
    }
    sslProfile: {
      id: resourceId('Microsoft.Network/applicationGateways/sslProfiles', appGatewayName, '${appGatewayName}-SSLProfile-Sodexo')
    }
    firewallPolicy: {
      id: wafPolicies.id
    }
  }
} : {}

var httpListenersList0 = (enableHttpPort) ? [ httpListener80 ] : []
var httpListenersList = (enableHttpsPort) ? concat(httpListenersList0, [ httpListener443 ]) : httpListenersList0

var dummyRoutingRuleListenerName = (enableHttpPort) ? '${appGatewayName}-Listener-80' : (enableHttpsPort) ? '${appGatewayName}-Listener-443' : 'NotConfigured'

// ==================================== Public IP Address ====================================

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-IP01-${appGatewayName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: 'Static'
    deleteOption: 'Delete'
    dnsSettings: {
      domainNameLabel: 'crecesdx'
    }
  }
  tags: standardTags
}

// ==================================== Web Application Firewall Policies ====================================

resource wafPolicies 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-WP01'
  location: location
  properties: {
    policySettings: {
      state: 'Enabled'
      mode: wafPoliciesMode
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

// ==================================== Managed Identity ====================================

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

// ==================================== Diagnotics ====================================

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM05'
  scope: appGateway
  properties: {
    workspaceId: resourceId('Microsoft.OperationalInsights/workspaces', diagnosticsWorkspaceName)
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
    ]
  }
}

// ==================================== Resource Lock ====================================

resource appGatewayLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL05'
  scope: appGateway
  properties: {
    level: 'CanNotDelete'
    notes: 'Application Gateway should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the Application Gateway.')
output applicationGatewayId string = appGateway.id

@description('Name of the Application Gateway.')
output applicationGatewayName string = appGateway.name
