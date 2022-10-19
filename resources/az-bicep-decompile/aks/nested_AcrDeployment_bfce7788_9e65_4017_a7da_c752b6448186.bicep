resource sodexocreceracr01 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: 'sodexocreceracr01'
  location: 'eastus2'
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: {
    Organization: 'Sodexo'
    System: 'SodexoCrecer'
    Environment: 'SWODEV'
  }
}