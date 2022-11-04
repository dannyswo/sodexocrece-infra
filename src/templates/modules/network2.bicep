@description('Azure region.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Standard name of the Main VNet.')
@minLength(4)
@maxLength(4)
param vnetName string

@description('IP range or CIDR of the Main VNet.')
param vnetAddressPrefix string

@description('Names and IP ranges of the Subnets.')
@metadata({
  name: 'Standard name of the Subnet.'
  addressPrefix: 'IP range or CIDR of the Subnet.'
  example: [
    {
      name: 'SN01'
      addressPrefix: '10.169.72.64/27'
    }
  ]
})
param subnetsAddressPrefixes array

resource mainVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${vnetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

@batchSize(1)
resource vnetSubnets 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = [for subnet in subnetsAddressPrefixes: {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-${subnet.name}'
  parent: mainVNet
  properties: {
    addressPrefix: subnet.addressPrefix
  }
}]

var subnetsData = [for (item, index) in subnetsAddressPrefixes: {
  subnetId: vnetSubnets[index].id
  subnetName: vnetSubnets[index].name
}]

@description('ID of the created VNet.')
output vnetId string = mainVNet.id

@description('IDs and names of the created Subnets.')
@metadata({
  subnetId: 'ID of the Subnet.'
  subnetName: 'Standard name of the Subnet.'
  example: [
    {
      subnetId: '/vnet/abc/subnet/123-456-789'
      subnetName: 'SN01'
    }
  ]
})
output subnets array = subnetsData
