targetScope = 'subscription'

@description('Azure region where resource group will be created')
param location string = 'eastus2'

resource locationsProcessorGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'sodexocrecer-rg02'
  location: location
}
