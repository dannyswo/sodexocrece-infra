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
param sqlDatabaseSQLAdminNameSecretName string

@description('Value of the sqlAdminLoginName Secret.')
@secure()
param sqlDatabaseSQLAdminNameSecretValue string

@description('Name of the sqlAdminLoginPass Secret, used by Azure SQL Database.')
param sqlDatabaseSQLAdminPassSecretName string

@description('Value of the sqlAdminLoginPass Secret. Optional, can be generated.')
@secure()
param sqlDatabaseSQLAdminPassSecretValue string = ''

@description('Name of the aadAdminLoginName Secret, used by Azure SQL Database.')
param sqlDatabaseAADAdminNameSecretName string

@description('Value of the aadAdminLoginName Secret.')
@secure()
param sqlDatabaseAADAdminNameSecretValue string

@description('Issue datetime of the generated Secrets.')
param secrtsIssueDateTime string

@description('If Certificates for Azure Services will be imported or not.')
param importCertificates bool

@description('Name of the public certificate used by Application Gateway.')
param appGatewayPublicCertificateName string

@description('File path of the public certificate.')
param appGatewayPublicCertificatePath string

@description('Name of the private certificate used by Application Gateway.')
param appGatewayPrivateCertificateName string

@description('File path of the private certificate.')
param appGatewayPrivateCertificatePath string

// ==================================== Resource definitions ====================================

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

var expiryTime = 'P1Y'
var timeAfterCreate = 'P11M'
var timeBeforeExpiry = 'P2M'

// ==================================== Encryption Keys ====================================

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

resource sqlDatabaseSQLAdminNameSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createSecrets) {
  name: sqlDatabaseSQLAdminNameSecretName
  parent: keyVault
  properties: {
    value: sqlDatabaseSQLAdminNameSecretValue
    contentType: 'text/plain'
    attributes: {
      enabled: true
      exp: secretsExpiryDateTimeSinceEpoch
    }
  }
}

resource sqlDatabaseSQLAdminPassScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (createSecrets && enableRandomPasswordsGeneration) {
  name: 'sqlDatabaseSQLAdminPassScript'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.0'
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    scriptContent: loadTextContent('../../scripts/Generate-RandomPassword.ps1')
  }
}

var secretsExpiryDateTime = dateTimeAdd(secrtsIssueDateTime, expiryTime)
var secretsExpiryDateTimeSinceEpoch = dateTimeToEpoch(secretsExpiryDateTime)

resource sqlDatabaseSQLAdminPassSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if (createSecrets) {
  name: sqlDatabaseSQLAdminPassSecretName
  parent: keyVault
  properties: {
    value: (enableRandomPasswordsGeneration) ? sqlDatabaseSQLAdminPassScript.properties.outputs.Result : sqlDatabaseSQLAdminPassSecretValue
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

// ==================================== Certificates ====================================

resource appGatewayPrivateCertificateImportScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (importCertificates) {
  name: 'appGatewayPrivateCertificateImportScript'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    arguments: '\'${keyVault.name}\' \'${appGatewayPrivateCertificateName}\' \'${appGatewayPrivateCertificatePath}\''
    scriptContent: loadTextContent('../../scripts/import-keyvault-certificate.sh')
  }
}

resource appGatewayPublicCertificateImportScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (importCertificates) {
  name: 'appGatewayPublicCertificateImportScript'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    arguments: '\'${keyVault.name}\' \'${appGatewayPublicCertificateName}\' \'${appGatewayPublicCertificatePath}\''
    scriptContent: loadTextContent('../../scripts/import-keyvault-certificate.sh')
  }
}

// ==================================== Outputs ====================================

@description('ID of the applications data Storage Account Encryption Key.')
output appsDataStorageEncryptionKeyId string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.id : ''

@description('Name of the applications data Storage Account Encryption Key.')
output appsDataStorageEncryptionKeyName string = (createEncryptionKeys) ? appsDataStorageEncryptionKey.name : appsDataStorageEncryptionKeyName

@description('ID of the Application Gateway private Certificate.')
output appGatewayPrivateCertificateId string = (importCertificates) ? appGatewayPrivateCertificateImportScript.properties.outputs.Result : ''

@description('ID of the Application Gateway public Certificate.')
output appGatewayPublicCertificateId string = (importCertificates) ? appGatewayPublicCertificateImportScript.properties.outputs.Result : ''
