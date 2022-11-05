@description('Azure region to deploy the Key Vault.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Suffix used in the Key Vault name.')
@minLength(6)
@maxLength(6)
param keyVaultNameSuffix string

@description('ID of the AAD Tenant used to authenticate requests to the Key Vault.')
param tenantId string = subscription().tenantId

@description('List of Subnet names allowed to access the Key Vault in the firewall.')
param allowedSubnetNames array = []

@description('List of IPs or CIDRs allowed to access the Key Vault in the firewall.')
param allowedIPsOrCIDRs array = []

@description('Standard tags applied to all resources.')
param standardTags object = resourceGroup().tags

var virtualNetworkRules = [for allowedSubnetName in allowedSubnetNames: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', allowedSubnetName)
  ignoreMissingVnetServiceEndpoint: true
}]

var ipRules = [for allowedIPOrCIDR in allowedIPsOrCIDRs: {
  value: allowedIPOrCIDR
}]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'azmxkv1${keyVaultNameSuffix}'
  location: location
  properties: {
    createMode: 'default'
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 1
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableRbacAuthorization: false
    accessPolicies: []
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: virtualNetworkRules
      ipRules: ipRules
    }
  }
  tags: standardTags
}

resource keyVaultLock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-AL01'
  scope: keyVault
  properties: {
    level: 'CanNotDelete'
    notes: 'Key Vault should not be deleted.'
  }
}

@description('ID of the Key Vault instance.')
output keyVaultId string = keyVault.id

@description('NAmeof the Key Vault instance.')
output keyVaultName string = keyVault.name

@description('URI of the Key Vault instance.')
output keyVaultUri string = keyVault.properties.vaultUri
