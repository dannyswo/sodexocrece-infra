param location string

@allowed([
  'dev'
  'qa'
  'uat'
  'prod'
])
param environmentType string = 'dev'

var appServicePlanName = 'asp01azcowin${environmentType}'

var environmentConfigurationMap = {
  dev: {
    appServicePlan: {
      name: appServicePlanName
      sku: {
        name: 'B1'
        capacity: 1
      }
      kind: 'linux'
    }
  }
  qa: {
    appServicePlan: {
      name: appServicePlanName
      sku: {
        name: 'B1'
        capacity: 1
      }
      kind: 'linux'
    }
  }
  uat: {
    appServicePlan: {
      name: appServicePlanName
      sku: {
        name: 'B1'
        capacity: 1
      }
      kind: 'linux'
    }
  }
  prod: {
    appServicePlan: {
      name: appServicePlanName
      sku: {
        name: 'B1'
        capacity: 1
      }
      kind: 'linux'
    }
  }
}


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: environmentConfigurationMap[environmentType].appServicePlan.name
  location:  location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
  kind: environmentConfigurationMap[environmentType].appServicePlan.kind
}


output appServicePlanId string = appServicePlan.id
