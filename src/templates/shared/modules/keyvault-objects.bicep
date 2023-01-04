/**
 * Module: keyvault-objects
 * Depends on: keyvault
 * Used by: shared/main-shared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the Key Vault.')
param keyVaultName string

@description('If Encryption Keys for Azure Services will be created or not.')
param createEncryptionKeys bool

@description('Name of the applications Storage Account Encryption Key.')
param appsStorageAccountEncryptionKeyName string

@description('Name of the Container Registry Encryption Key.')
param acrEncryptionKeyName string

@description('Name of the Merchant Portal Encryption Key.')
param merchantPortalEncryptionKeyName string

@description('Issue datetime of the generated Encryption Keys.')
param encryptionKeysIssueDateTime string

@description('If Secrets for Azure Services will be created or not.')
param createSecrets bool

@description('Name of the sqlAdminLoginName Secret, used by Azure SQL Database.')
param sqlDatabaseSqlAdminNameSecretName string

@description('Value of the sqlAdminLoginName Secret.')
@secure()
param sqlDatabaseSqlAdminNameSecretValue string

@description('Name of the sqlAdminLoginPass Secret, used by Azure SQL Database.')
param sqlDatabaseSqlAdminPassSecretName string

@description('Value of the sqlAdminLoginPass Secret.')
@secure()
param sqlDatabaseSqlAdminPassSecretValue string

@description('Issue datetime of the generated Secrets.')
param secrtsIssueDateTime string

// ==================================== Resources ====================================

// ==================================== Encryption Keys ====================================

var expiryTime = 'P1Y'
var timeAfterCreate = 'P11M'
var timeBeforeExpiry = 'P2M'

var expiryDateTime = dateTimeAdd(encryptionKeysIssueDateTime, expiryTime)
var expiryDateTimeSinceEpoch = dateTimeToEpoch(expiryDateTime)

resource appsStorageAccountEncryptionKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = if (createEncryptionKeys) {
  name: appsStorageAccountEncryptionKeyName
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

resource acrEncryptionKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = if (createEncryptionKeys) {
  name: acrEncryptionKeyName
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

resource merchantPortalEncryptionKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = if (createEncryptionKeys) {
  name: merchantPortalEncryptionKeyName
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

var secretsExpiryDateTime = dateTimeAdd(secrtsIssueDateTime, expiryTime)
var secretsExpiryDateTimeSinceEpoch = dateTimeToEpoch(secretsExpiryDateTime)

resource sqlDatabaseSqlAdminNameSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createSecrets) {
  name: sqlDatabaseSqlAdminNameSecretName
  parent: keyVault
  properties: {
    value: (sqlDatabaseSqlAdminNameSecretValue != '') ? sqlDatabaseSqlAdminNameSecretValue : null
    contentType: 'text/plain'
    attributes: {
      enabled: true
      exp: secretsExpiryDateTimeSinceEpoch
    }
  }
}

resource sqlDatabaseSqlAdminPassSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createSecrets) {
  name: sqlDatabaseSqlAdminPassSecretName
  parent: keyVault
  properties: {
    value: (sqlDatabaseSqlAdminPassSecretValue != '') ? sqlDatabaseSqlAdminPassSecretValue : null
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

@description('Name of the applications Storage Account Encryption Key.')
output appsStorageAccountEncryptionKeyName string = (createEncryptionKeys) ? appsStorageAccountEncryptionKey.name : ''

@description('URI of the applications Storage Account Encryption Key.')
output appsStorageAccountEncryptionKeyUri string = (createEncryptionKeys) ? appsStorageAccountEncryptionKey.properties.keyUri : ''

@description('Name of the Container Registry Encryption Key.')
output acrEncryptionKeyName string = (createEncryptionKeys) ? acrEncryptionKey.name : ''

@description('URI of the Container Registry Encryption Key.')
output acrEncryptionKeyUri string = (createEncryptionKeys) ? acrEncryptionKey.properties.keyUri : ''

@description('Name of the Container Registry Encryption Key.')
output merchantPortalEncryptionKeyName string = (createEncryptionKeys) ? merchantPortalEncryptionKey.name : ''

@description('URI of the Container Registry Encryption Key.')
output merchantPortalEncryptionKeyUri string = (createEncryptionKeys) ? merchantPortalEncryptionKey.properties.keyUri : ''

@description('Name of the SQL Database SQL admin name Secret.')
output sqlDatabaseSqlAdminNameSecretName string = (createSecrets) ? sqlDatabaseSqlAdminNameSecret.name : ''

@description('URI of the SQL Database SQL admin name Secret.')
output sqlDatabaseSqlAdminNameSecretUri string = (createSecrets) ? sqlDatabaseSqlAdminNameSecret.properties.secretUri : ''

@description('Name of the SQL Database SQL admin password Secret.')
output sqlDatabaseSqlAdminPassSecretName string = (createSecrets) ? sqlDatabaseSqlAdminPassSecret.name : ''

@description('URI of the SQL Database SQL admin password Secret.')
output sqlDatabaseSqlAdminPassSecretUri string = (createSecrets) ? sqlDatabaseSqlAdminPassSecret.properties.secretUri : ''
