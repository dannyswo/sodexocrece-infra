/**
 * Module: network-security-groups
 * Depends on: network-references-shared
 * Used by: system/main-shared
 * Common resources: N/A
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

@description('Standard tags applied to all resources.')
param standardTags object = resourceGroup().tags

// ==================================== Resource properties ====================================

@description('List of allowed CIDRs in the Gateway Subnet.')
param gatewayNSGSourceAddressPrefixes array

@description('List of allowed CIDRs in the AKS Subnet.')
param aksNSGSourceAddressPrefixes array

// ==================================== Resources ====================================

// ==================================== Network Security Groups ====================================

resource gatewayNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS01'
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
  name: 'BRS-MEX-USE2-CRECESDX-${env}-NS02'
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

// ==================================== Outputs ====================================

@description('ID of the NSG for Gateway Subnet.')
output gatewayNSGId string = gatewayNSG.id

@description('ID of the NSG for AKS Subnet.')
output aksNSGId string = aksNSG.id
