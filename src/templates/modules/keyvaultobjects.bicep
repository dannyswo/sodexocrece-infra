@description('Name of the Key Vault.')
param keyVaultName string

@description('If Encryption Keys for Azure Services will be created or not.')
param createEncryptionKeys bool

@description('Name of the Encryption Key used by Application Data Storage Account.')
param appsDataStorageEncryptionKeyName string

@description('If empty Secrets for Applications will be created or not.')
param createEmptySecrets bool

@description('Name of the admin user Secret used by Azure SQL Database.')
param sqlDatabaseAdminUserSecretName string

@description('Name of the admin password Secret used by Azure SQL Database.')
param sqlDatabaseAdminPassSecretName string

//param createCertificates bool

//param appGatewayPublicCertificateName string

//param appGatewayPrivateCertificateName string

@description('Issue date time of the generated Encryption Keys.')
param encryptionKeysIssueDateTime string = utcNow()

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

var expiryTime = 'P1Y'
var beforeExpiryTime = '-P30M'

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
        expiryTime: 'P1Y'
      }
      lifetimeActions: [
        {
          action: {
            type: 'rotate'
          }
          trigger: {
            timeBeforeExpiry: beforeExpiryTime
          }
        }
        {
          action: {
            type: 'notify'
          }
          trigger: {
            timeBeforeExpiry: beforeExpiryTime
          }
        }
      ]
    }
  }
}

resource sqlDatabaseAdminUserSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createEmptySecrets) {
  name: sqlDatabaseAdminUserSecretName
  parent: keyVault
  properties: {
    value: 'changeit'
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
}

resource sqlDatabaseAdminPassSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createEmptySecrets) {
  name: sqlDatabaseAdminPassSecretName
  parent: keyVault
  properties: {
    value: 'changeit'
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
}

output appsDataStorageEncryptionKeyId string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.id : ''

output appsDataStorageEncryptionKeyName string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.name : appsDataStorageEncryptionKeyName

output sqlDatabaseAdminUserSecretId string = (createEmptySecrets) ? sqlDatabaseAdminUserSecret.id : ''

output sqlDatabaseAdminPassSecretId string = (createEmptySecrets) ? sqlDatabaseAdminPassSecret.id : ''
