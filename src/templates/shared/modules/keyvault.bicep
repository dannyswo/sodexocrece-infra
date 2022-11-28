/**
 * Module: keyvault
 * Depends on: monitoring-loganalytics-workspace
 * Used by: shared/main-shared
 * Common resources: RL04, MM04
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

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

// ==================================== Resource properties ====================================

@description('Suffix used in the Key Vault name.')
@minLength(6)
@maxLength(6)
param keyVaultNameSuffix string

@description('Enable purge protection feature of the Key Vault.')
param enablePurgeProtection bool

@description('Retention days of soft-deleted objects in the Key Vault.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionDays int

@description('Enable ARM to access objects in the Key Vault.')
param enableArmAccess bool

@description('ID of the AAD Tenant used to authenticate requests to the Key Vault.')
param tenantId string = subscription().tenantId

@description('Enable RBAC authorization in Key Vault and ignore access policies.')
param enableRbacAuthorization bool

// ==================================== Diagnostics options ====================================

@description('Enable diagnostics to store Key Vault audit logs.')
param enableDiagnostics bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Key Vault. Must be defined if enableDiagnostics is true.')
param diagnosticsWorkspaceName string

@description('Retention days of the Key Vault audit logs. Must be defined if enableDiagnostics is true.')
@minValue(7)
@maxValue(180)
param logsRetentionDays int

// ==================================== Resource Lock switch ====================================

@description('Enable Resource Lock on Key Vault.')
param enableLock bool

// ==================================== PaaS Firewall settings ====================================

@description('Enable public access in the PaaS firewall.')
param enablePublicAccess bool

@description('Allow bypass of PaaS firewall rules to Azure Services.')
param bypassAzureServices bool

@description('List of Subnets allowed to access the Key Vault in the PaaS firewall.')
@metadata({
  vnetName: 'Name of the VNet.'
  subnetName: 'Name of the Subnet'
})
param allowedSubnets array

@description('List of IPs or CIDRs allowed to access the Key Vault in the PaaS firewall.')
param allowedIPsOrCIDRs array

@description('Standard tags applied to all resources.')
param standardTags object

// ==================================== Resources ====================================

// ==================================== Key Vault ====================================

var virtualNetworkRules = [for allowedSubnet in allowedSubnets: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', allowedSubnet.vnetName, allowedSubnet.subnetName)
  ignoreMissingVnetServiceEndpoint: false
}]

var ipRules = [for allowedIPOrCIDR in allowedIPsOrCIDRs: {
  value: allowedIPOrCIDR
}]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'azmxkv1${keyVaultNameSuffix}'
  location: location
  properties: {
    createMode: 'default'
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: true
    enablePurgeProtection: enablePurgeProtection
    softDeleteRetentionInDays: softDeleteRetentionDays
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: enableArmAccess
    tenantId: tenantId
    enableRbacAuthorization: enableRbacAuthorization
    accessPolicies: []
    publicNetworkAccess: (enablePublicAccess) ? 'Enabled' : 'Disabled'
    networkAcls: {
      bypass: (bypassAzureServices) ? 'AzureServices' : 'None'
      defaultAction: 'Deny'
      virtualNetworkRules: virtualNetworkRules
      ipRules: ipRules
    }
  }
  tags: standardTags
}

// ==================================== Diagnostics ====================================

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-MM04'
  scope: keyVault
  properties: {
    workspaceId: resourceId('Microsoft.OperationalInsights/workspaces', diagnosticsWorkspaceName)
    logs: [
      {
        category: 'AuditEvent'
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

resource keyVaultLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableLock) {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-RL04'
  scope: keyVault
  properties: {
    level: 'CanNotDelete'
    notes: 'Key Vault should not be deleted.'
  }
}

// ==================================== Outputs ====================================

@description('ID of the Key Vault instance.')
output keyVaultId string = keyVault.id

@description('Name of the Key Vault instance.')
output keyVaultName string = keyVault.name

@description('URI of the Key Vault instance.')
output keyVaultUri string = keyVault.properties.vaultUri
