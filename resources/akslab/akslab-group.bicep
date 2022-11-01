targetScope = 'subscription'

@description('Azure region where Resource Group will be created.')
param location string = 'eastus2'

resource sodexocreceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'sodexocrece-rg01'
  location: location
}
