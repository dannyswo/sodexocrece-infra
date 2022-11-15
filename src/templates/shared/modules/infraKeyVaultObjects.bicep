/**
 * Module: infraKeyVaultObjects
 * Depends on: infraKeyVault
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Name of the Key Vault.')
param keyVaultName string

@description('If Encryption Keys for Azure Services will be created or not.')
param createEncryptionKeys bool

@description('Name of the appsDataStorage Encryption Key.')
param appsDataStorageEncryptionKeyName string

@description('Issue datetime of the generated Encryption Keys.')
param encryptionKeysIssueDateTime string

@description('If Secrets for Azure Services will be created or not.')
param createSecrets bool

@description('Enable the generation of random passwords.')
param enableRandomPasswordsGeneration bool

@description('Name of the sqlAdminLoginName Secret, used by Azure SQL Database.')
param sqlDatabaseSqlAdminNameSecretName string

@description('Value of the sqlAdminLoginName Secret.')
@secure()
param sqlDatabaseSqlAdminNameSecretValue string

@description('Name of the sqlAdminLoginPass Secret, used by Azure SQL Database.')
param sqlDatabaseSqlAdminPassSecretName string

@description('Value of the sqlAdminLoginPass Secret. Optional, can be autogenerated.')
@secure()
param sqlDatabaseSqlAdminPassSecretValue string

@description('Name of the aadAdminLoginName Secret, used by Azure SQL Database.')
param sqlDatabaseAADAdminNameSecretName string

@description('Value of the aadAdminLoginName Secret, used by Azure SQL Database.')
@secure()
param sqlDatabaseAADAdminNameSecretValue string

@description('Issue datetime of the generated Secrets.')
param secrtsIssueDateTime string

// ==================================== Resources ====================================

// ==================================== Encryption Keys ====================================

var expiryTime = 'P1Y'
var timeAfterCreate = 'P11M'
var timeBeforeExpiry = 'P2M'

var expiryDateTime = dateTimeAdd(encryptionKeysIssueDateTime, expiryTime)
var expiryDateTimeSinceEpoch = dateTimeToEpoch(expiryDateTime)

resource appsDataStorageEncryptionKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = if (createEncryptionKeys) {
  name: appsDataStorageEncryptionKeyName
  parent: keyVault
  properties: {
    kty: 'RSA'
    keySize: 4096
    attributes: {
      enabled: true
      exp: expiryDateTimeSinceEpoch
      exportable: false
    }
    rotationPolicy: {
      attributes: {
        expiryTime: expiryTime
      }
      lifetimeActions: [
        {
          action: {
            type: 'rotate'
          }
          trigger: {
            timeAfterCreate: timeAfterCreate
          }
        }
        {
          action: {
            type: 'notify'
          }
          trigger: {
            timeBeforeExpiry: timeBeforeExpiry
          }
        }
      ]
    }
  }
}

// ==================================== Secrets ====================================

resource sqlDatabaseSqlAdminNameSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createSecrets) {
  name: sqlDatabaseSqlAdminNameSecretName
  parent: keyVault
  properties: {
    value: sqlDatabaseSqlAdminNameSecretValue
    contentType: 'text/plain'
    attributes: {
      enabled: true
      exp: secretsExpiryDateTimeSinceEpoch
    }
  }
}

resource sqlDatabaseSqlAdminPassScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (createSecrets && enableRandomPasswordsGeneration) {
  name: 'sqlDatabaseSqlAdminPassScript'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.0'
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    scriptContent: loadTextContent('../../../scripts/Generate-RandomPassword.ps1')
  }
}

var secretsExpiryDateTime = dateTimeAdd(secrtsIssueDateTime, expiryTime)
var secretsExpiryDateTimeSinceEpoch = dateTimeToEpoch(secretsExpiryDateTime)

resource sqlDatabaseSqlAdminPassSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createSecrets) {
  name: sqlDatabaseSqlAdminPassSecretName
  parent: keyVault
  properties: {
    value: (enableRandomPasswordsGeneration) ? sqlDatabaseSqlAdminPassScript.properties.outputs.Result : sqlDatabaseSqlAdminPassSecretValue
    contentType: 'text/plain'
    attributes: {
      enabled: true
      exp: secretsExpiryDateTimeSinceEpoch
    }
  }
}

resource sqlDatabaseAADAdminNameSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createSecrets) {
  name: sqlDatabaseAADAdminNameSecretName
  parent: keyVault
  properties: {
    value: sqlDatabaseAADAdminNameSecretValue
    contentType: 'text/plain'
    attributes: {
      enabled: true
      exp: secretsExpiryDateTimeSinceEpoch
    }
  }
}

// ==================================== Key Vault ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

// ==================================== Outputs ====================================

@description('ID of the applications data Storage Account Encryption Key.')
output appsDataStorageEncryptionKeyId string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.id : ''

@description('Name of the applications data Storage Account Encryption Key.')
output appsDataStorageEncryptionKeyName string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.name : ''
