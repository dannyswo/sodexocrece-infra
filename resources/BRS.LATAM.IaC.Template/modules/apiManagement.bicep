param location string
param publisherEmail string = 'carlos.arboleda@softwareone.com'
param publisherName string = 'Colorin'
param apiManagementPoliciesValue string = ''

param apiManagementName string = 'colorin'

@allowed([
  'dev'
  'qa'
  'uat'
  'prod'
])
param environmentType string = 'dev'

var apiManagementSku = {
  dev: {
       sku: {
         name: 'Developer'
         capacity: 1
       }
  }
  prod: {
   sku: {
     name: 'Developer'
     capacity: 1
   }
  }
 }

resource apiManagementColorin 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: '${apiManagementName}-${environmentType}'
  location: location
  sku: apiManagementSku[environmentType].sku
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource apiManagementPolicies 'Microsoft.ApiManagement/service/policies@2021-12-01-preview' = {
  name: 'apiManagementPolicies/policy'
  dependsOn: [
     apiManagementColorin
  ]
  properties: {
    value: apiManagementPoliciesValue
  }
}

output apiManagementIp string = apiManagementColorin.properties.publicIpAddressId
