param kvResourceGroup string
param kvName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
  scope: resourceGroup()
}

module databaseModule './modules/database.bicep' = {
  name: 'databaseModule'
  params: {
    administratorLogin: keyVault.getSecret('adminLogin')
  }
}
