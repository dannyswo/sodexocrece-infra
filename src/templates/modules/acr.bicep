@description('Azure region to deploy the Container Registry.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param environment string

@description('Suffix used in the Container Registry name.')
@minLength(6)
@maxLength(6)
param acrNameSuffix string

@description('Selected tier for the Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string

@description('If zone redundancy Enabled or Disabled for the Container Registry.')
@allowed([
  'Enabled'
  'Disabled'
])
param zoneRedundancy string

@description('Retention days of untagged images in the Container Registry.')
param untaggedRetentionDays int

@description('Retention days of soft deleted images in the Container Registry.')
param softDeleteRetentionDays int

resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'azmxcr1${acrNameSuffix}'
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    zoneRedundancy: zoneRedundancy
    policies: {
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        status: 'enabled'
        days: untaggedRetentionDays
      }
      softDeletePolicy: {
        status: 'enabled'
        retentionDays: softDeleteRetentionDays
      }
      exportPolicy: {
        status: 'disabled'
      }
    }
    adminUserEnabled: false
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'None'
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: []
    }
  }
  tags: resourceGroup().tags
}

@description('ID of the Container Registry.')
output registryId string = registry.id

@description('URL used to log in into the Container Registry.')
output loginURL string = registry.properties.loginServer
