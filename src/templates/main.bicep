param kvResourceGroup string
param kvName string
param enableDbPrivateEndpoint bool = false
param enableKVPrivateEndpoint bool = false
param enableBSPrivateEndpoint bool = false
param enableNetwork bool = false
param location string = resourceGroup().location
param environment string 
param tags object 
// = {
//   ApplicationName : ''
//   ApplicationOwner : ''
//   ApplicationSponsor : ''
//   TechnicalContact : ''
//   Billing : ''
//   Maintenance : ''
//   EnvironmentType : ''
//   Security : ''
//   DeploymentDate : ''
// }
param subnets array 
// = [
//   {
//     name: 'SN01'
//     addressPrefix: '10.169.91.0/28'
//   }
//   {
//     name: 'SN02'
//     addressPrefix: '10.169.91.16/28'
//   }
// ]

param vnetPrefix string
param kvSKU object
param objectId string
param tenantId string
param existingAGWSubnetName string

var agwSubnetIndex = 0
var aksSubnetIndex = 1
var PESubnetIndex = 2

module networkModule 'modules/network.bicep' = if (enableNetwork){
  name: 'networkModule'
  params: {
    environment: environment
    location: location
    tags: tags
    subnets: subnets
    vnetPrefix: vnetPrefix
  }
}

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'kvModule'
  params: {
    location: location
    sku: kvSKU
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    objectId: objectId
    tenantId: tenantId
    keysPermissions: [
      'all'
    ]
    secretsPermissions: [
      'all'
    ]
  }
}

var subnetNameAGW = enableNetwork ? networkModule.outputs.subnetIds[agwSubnetIndex].id : existingAGWSubnetName

module appGateWayModule 'modules/agw.bicep' = {
  name: 'appGateWayModule'
  params: {
    subnetName: subnetNameAGW
    location: location
  }
}

module acrModule 'modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    
  }
}

module kvPrivateEndpoint 'modules/privateendpoint.bicep' = if(enableKVPrivateEndpoint && enableNetwork){
  name: 'kvPrivateEndpoint'
  params: {
    privateEndpointName: 'kvPrivateEndpoint'
    serviceId: keyVaultModule.outputs.keyVaultId
    location: location
    subnetId: networkModule.outputs.subnetIds[PESubnetIndex].id
    groupIds: [
      'KVPE'
    ]
  }
}

module databaseModule './modules/database.bicep' = {
  name: 'databaseModule'
  params: {
    administratorLogin: keyVault.getSecret('adminLogin')
  }
}

module dbPrivateEndpoint 'modules/privateendpoint.bicep' = if(enableDbPrivateEndpoint && enableNetwork){
  name: 'dbPrivateEndpoint'
  params: {
    privateEndpointName: 'dbPrivateEndpoint'
    serviceId: databaseModule.outputs.databaseId
    location: location
    subnetId: networkModule.outputs.subnetIds[PESubnetIndex].id
    groupIds: [
      'DBPE'
    ]
  }
}
