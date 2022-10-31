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
param subnetsVnetSA array 
param subnetsVnetFE array 
param subnetsVnetPE array 
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

param vnetPrefixSA string //  ex. = '10.169.91.0/27'
param vnetPrefixFE string
param vnetPrefixPE string

param kvSKU object
param objectId string
param tenantId string
param existingAGWSubnetName string
param secretCreated bool

var agwSubnetIndex = 0
var aksSubnetIndex = 1
var PESubnetIndex = 1

module vnetAppFEModule 'modules/network.bicep' = if (enableNetwork){
  name: 'vnetAppFE'
  params: {
    environment: environment
    location: location
    subnets: subnetsVnetFE
    vnetPrefix: vnetPrefixFE
    vnetNumber: '01'
  }
}

module vnetPrivateEndpointsModule 'modules/network.bicep' = if (enableNetwork){
  name: 'vnetPrivateEndpoints'
  params: {
    environment: environment
    location: location
    subnets: subnetsVnetPE
    vnetPrefix: vnetPrefixPE
    vnetNumber: '02'
  }
}

module vnetSharedAppModule 'modules/network.bicep' = if (enableNetwork){
  name: 'vnetSharedApp'
  params: {
    environment: environment
    location: location
    subnets: subnetsVnetSA
    vnetPrefix: vnetPrefixSA
    vnetNumber: '03'
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
      'get'
      'verify'
    ]
    secretsPermissions: [
      'get'
    ]
  }
}

module kvPrivateEndpoint 'modules/privateendpoint.bicep' = if(enableKVPrivateEndpoint && enableNetwork){
  name: 'kvPrivateEndpoint'
  params: {
    privateEndpointName: 'kvPrivateEndpoint'
    serviceId: keyVaultModule.outputs.keyVaultId
    location: location
    subnetId: vnetPrivateEndpointsModule.outputs.subnetIds[PESubnetIndex].id
    groupIds: [
      'KVPE'
    ]
  }
}

module databaseModule './modules/database.bicep' = if (secretCreated){
  name: 'databaseModule'
  params: {
    administratorLogin: keyVaultModule.getSecret('adminLogin')
    administratorLoginPassword:keyVaultModule.getSecret('adminLoginPW')
    administrators: [
      //missing object
    ]
    randomString: 'urp'
    randomNumber: '154'
    location: location
  }
}

module dbPrivateEndpointModule 'modules/privateendpoint.bicep' = if(secretCreated && enableDbPrivateEndpoint && enableNetwork){
  name: 'dbPrivateEndpoint'
  params: {
    privateEndpointName: 'dbPrivateEndpoint'
    serviceId: databaseModule.outputs.databaseId
    location: location
    subnetId: vnetPrivateEndpointsModule.outputs.subnetIds[PESubnetIndex].id
    groupIds: [
      'DBPE'
    ]
  }
}

var subnetNameAGW = enableNetwork ? vnetSharedAppModule.outputs.subnetIds[agwSubnetIndex].id : existingAGWSubnetName

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






