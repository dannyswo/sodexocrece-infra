param location string = resourceGroup().location
param environment string

var businessLine = 'BRS'
var businessRegion = 'LATAM'
var cloudRegion = 'USE2'
var projectName = 'CRECESDX'

resource symbolicname 'Microsoft.Network/networkWatchers@2022-05-01' = {
  name: '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}-NW01'
  location: location
}
