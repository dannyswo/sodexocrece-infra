param location string


@allowed([
  'dev'
  'qa'
  'uat'
  'prod'
])
param environmentType string = 'dev'

var storageAccountSku = {
  dev: {
       sku: {
         name: 'Standard_LRS'
         tier: 'Standard'
       }
       kind: 'StorageV2'
  }
  prod: {
   sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
   }
   kind: 'StorageV2'
  }
 }

var storageAccountName = 'sa01azcowint${environmentType}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: storageAccountSku[environmentType].sku
  kind: storageAccountSku[environmentType].kind

}

output storageAccountEndpoint string = storageAccount.properties.primaryEndpoints.blob
