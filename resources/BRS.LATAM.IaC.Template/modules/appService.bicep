param location string
param appServiceAppNames array
param ipAddressApiManagement string
param appServicePlanId string
param applicationsInsightsInstrumentationKey string
param applicationsInsightsConnectionString string

@allowed([
  'dev'
  'qa'
  'uat'
  'prod'
])
param environmentType string = 'dev'

@allowed([
  'front'
  'back'
])
param componentType string

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = [ for appServiceAppName in appServiceAppNames: {
  name: '${appServiceAppName}${environmentType}'
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationsInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationsInsightsConnectionString
        }
      ]
      linuxFxVersion: componentType == 'back' ? 'DOTNETCORE|6.0' : 'NODE|14-lts'
      ipSecurityRestrictions: [
        {
          ipAddress: ipAddressApiManagement
          action: 'Allow'
          tag: 'Default'
          priority: 100
          name: 'ApiManagement'
          description: 'Api Management'
        }
        {
          ipAddress: 'Any'
          action: 'Deny'
          priority: 2147483647
          name: 'Deny all'
          description: 'Deny all access'
        }
      ]
    }
  }
}]


output appServiceAppHostName array = [for i in range(0, length(appServiceAppNames)): { name: appServiceApp[i].properties.defaultHostName}]
