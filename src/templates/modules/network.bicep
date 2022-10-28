param location string = 'eastus2'
param vnetPrefix string = '10.169.91.0/27'
param subnets array 
// = [
//   {
//     name: 'SN01'
//     addressPrefix: '10.169.91.0/27'
//   }
//   {
//     name: 'SN02'
//     addressPrefix: '10.169.91.32/27'
//   }
//   {
//     name: 'SN03'
//     addressPrefix: '10.169.91.64/27'
//   }
// ]
param environment string = 'DEV'
param tags object

var businessLine = 'BRS'
var businessRegion = 'LATAM'
var cloudRegion = 'US'
var projectName = 'CRECESDX'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}-VNET01'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    enableDdosProtection: false
  }
}

@batchSize(1)
resource vnetSubnets 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = [ for subnet in subnets: {
  name: '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}-${subnet.name}'
  parent: virtualNetwork
  properties: {
    addressPrefix: subnet.addressPrefix
  }
}]

var subnetIds = [for (item, index) in subnets: {
  subnetId: vnetSubnets[index].id
  subnetName: vnetSubnets[index].name
}]

output vnetId string = virtualNetwork.id
output subnetIds array = subnetIds
