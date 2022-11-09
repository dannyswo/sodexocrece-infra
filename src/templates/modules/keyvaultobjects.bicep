@description('Name of the Key Vault.')
param keyVaultName string

@description('If Encryption Keys for Azure Services will be created or not.')
param createEncryptionKeys bool

@description('Name of the Encryption Key used by Application Data Storage Account.')
param appsDataStorageEncryptionKeyName string

@description('Issue date time of the generated Encryption Keys.')
param encryptionKeysIssueDateTime string

// ==================================== Resource definitions ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

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

output appsDataStorageEncryptionKeyId string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.id : ''

output appsDataStorageEncryptionKeyName string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.name : appsDataStorageEncryptionKeyName

output sqlDatabaseAdminUserSecretName string = 'merchant-admin-user'

output sqlDatabaseAdminPassSecretName string = 'merchant-admin-pass'
