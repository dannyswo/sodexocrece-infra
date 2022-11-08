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
param devopsKeyVaultNameSuffix string

@description('Enable purge protection feature of the Key Vault.')
param devopsKeyVaultEnablePurgeProtection bool

@description('Retention days of soft-deleted objects in the Key Vault.')
@minValue(7)
@maxValue(90)
param devopsKeyVaultSoftDeleteRetentionDays int

@description('Enable diagnostics to store Key Vault audit logs.')
param devopsKeyVaultEnableDiagnostics bool

@description('Name of the Log Analytics Workspace used for diagnostics of the Key Vault. Must be defined if enableDiagnostics is true.')
param devopsKeyVaultWorkspaceName string

@description('Retention days of the Key Vault audit logs. Must be defined if enableDiagnostics is true.')
@minValue(7)
@maxValue(180)
param devopsKeyVaultLogsRetentionDays int

@description('Enable Resource Lock on Key Vault.')
param devopsKeyVaultEnableLock bool

@description('Enable public access in the PaaS firewall.')
param devopsKeyVaultEnablePublicAccess bool

@description('List of Subnet names allowed to access the Key Vault in the PaaS firewall.')
param devopsKeyVaultAllowedSubnetNames array = []

@description('List of IPs or CIDRs allowed to access the Key Vault in the PaaS firewall.')
param devopsKeyVaultAllowedIPsOrCIDRs array = []

@description('Standard tags applied to all resources.')
param standardTags object = resourceGroup().tags

// Resource definitions

module devopsKeyVaultModule 'modules/keyvault.bicep' = {
  name: 'devopsKeyVaultModule'
  params: {
    location: location
    env: env
    keyVaultNameSuffix: devopsKeyVaultNameSuffix
    enablePurgeProtection: devopsKeyVaultEnablePurgeProtection
    softDeleteRetentionDays: devopsKeyVaultSoftDeleteRetentionDays
    enableDiagnostics: devopsKeyVaultEnableDiagnostics
    diagnosticsWorkspaceName: devopsKeyVaultWorkspaceName
    logsRetentionDays: devopsKeyVaultLogsRetentionDays
    enableLock: devopsKeyVaultEnableLock
    enablePublicAccess: devopsKeyVaultEnablePublicAccess
    allowedSubnetNames: devopsKeyVaultAllowedSubnetNames
    allowedIPsOrCIDRs: devopsKeyVaultAllowedIPsOrCIDRs
    standardTags: standardTags
  }
}
