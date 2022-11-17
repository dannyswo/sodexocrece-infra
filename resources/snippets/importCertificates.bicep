
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

// ==================================== Certificates ====================================

resource appGatewayPrivateCertificateImportScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (importCertificates) {
  name: 'appGatewayPrivateCertificateImportScript'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    arguments: '\'${keyVault.name}\' \'${appGatewayPrivateCertificateName}\' \'${appGatewayPrivateCertificatePath}\''
    scriptContent: loadTextContent('../../../scripts/import-keyvault-certificate.sh')
  }
}

resource appGatewayPublicCertificateImportScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (importCertificates) {
  name: 'appGatewayPublicCertificateImportScript'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    arguments: '\'${keyVault.name}\' \'${appGatewayPublicCertificateName}\' \'${appGatewayPublicCertificatePath}\''
    scriptContent: loadTextContent('../../../scripts/import-keyvault-certificate.sh')
  }
}

@description('ID of the Application Gateway private Certificate.')
output appGatewayPrivateCertificateId string = (importCertificates) ? appGatewayPrivateCertificateImportScript.properties.outputs.Result : ''

@description('ID of the Application Gateway public Certificate.')
output appGatewayPublicCertificateId string = (importCertificates) ? appGatewayPublicCertificateImportScript.properties.outputs.Result : ''
