/**
 * Module: network-security-groups
 * Depends on: network
 * Used by: system/main-shared
 * Common resources: N/A
 */

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

@description('Standard tags applied to all resources.')
@metadata({
  ApplicationName: 'ApplicationName'
  ApplicationOwner: 'ApplicationOwner'
  ApplicationSponsor: 'ApplicationSponsor'
  TechnicalContact: 'TechnicalContact'
  Maintenance: '{ ... } (maintenance standard JSON)'
  EnvironmentType: 'DEV | UAT | PRD'
  Security: '{ ... } (security standard JSON generated in Palantir)'
  DeploymentDate: 'YYY-MM-DDTHHMM UTC (autogenatered)'
  AllowShutdown: 'True (for non-prod environments), False (for prod environments)'
  dd_organization: 'MX (only for prod environments)'
  Env: 'dev | uat | prd'
  stack: 'Crececonsdx'
})
param standardTags object = resourceGroup().tags

@description('List of allowed CIDRs in the Gateway Subnet.')
param gatewayNSGSourceAddressPrefixes array

@description('List of allowed CIDRs in the AKS Subnet.')
param aksNSGSourceAddressPrefixes array

// ==================================== Resources ====================================

// ==================================== Network Security Groups ====================================

resource gatewayNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS06'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: '*'
          priority: 100
          description: 'Allow GatewayManager Azure Ports Inbound.'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow GatewayManager Azure Ports Inbound.'
        }
      }
      {
        name: 'AllowSodexoSubnetsHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: gatewayNSGSourceAddressPrefixes
          destinationPortRanges: [
            '80'
            '443'
          ]
          destinationAddressPrefix: '*'
          priority: 120
          description: 'Allow Sodexo Subnets HTTP Inbound.'
        }
      }
      {
        name: 'DenyInternetAllInbound'
        properties: {
          access: 'Deny'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          priority: 4096
          description: 'Deny Internet All Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}

resource aksNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS07'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSodexoSubnetsHttpInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefixes: aksNSGSourceAddressPrefixes
          destinationPortRanges: [
            '80'
            '443'
          ]
          destinationAddressPrefix: '*'
          priority: 100
          description: 'Allow Sodexo Subnets HTTP Inbound.'
        }
      }
      {
        name: 'DenyInternetAllInbound'
        properties: {
          access: 'Deny'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          priority: 4096
          description: 'Deny Internet All Inbound.'
        }
      }
    ]
  }
  tags: standardTags
}
