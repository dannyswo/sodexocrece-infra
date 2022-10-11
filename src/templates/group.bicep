targetScope = 'subscription'

@description('Logical environment where the resource group resides')
param environment string = 'swodev'

@description('Azure region where resource group will be created')
param location string = 'eastus'

@description('Common tags applied to all resources in the group')
param commonTags object

var systemName = 'gvdp'
var componentName = 'locationsprocessor'

resource locationsProcessorGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${systemName}-${environment}-${componentName}-${location}'
  location: location
  tags: union(commonTags, {
      Tier: 'Backend'
      Component: 'LocationsProcessor'
    })
}
