
param appServicePlanId string
param location string
param function_storage object
param endpointList array


resource functionApp 'Microsoft.Web/sites@2021-03-01' = [ for (app, i) in items(function_storage): {
  name: app.value.functionName
  location: location
  tags: {
    stack: 'Alicanto'
    ApplicationName: 'BRS.LATAM.CL.Alicanto'
    ApplicationOwner: 'ignacio.zamorano@sodexo.com'
    ApplicationSponsor: 'david.dussart@sodexo.com'
    Billing: '{"BSD":"2021-10-14T14:00:00","CC":"2531","D":"","LE":"Sodexo Pass International SAS","MUP":""}'
    environmentType: 'DEV'
    Maintenance: '{ "InternalAssetIdentifier":"", "Provider":"SoftwareONE", "ProviderAssetIdentifier";"", "MaintenanceWindow":"TBD", "ServiceLevel":"TBD" }'
    Security: '{"C":4,"I":4,"A":4,"ITCritical":1,"BusCritical":1,"Situation":"Exposed","DJ":0,"ITOps":"SoftwareONE","SecOps":"GISS","hasPD":1,"Scope":"Local","DRP":1}'
    TechnicalContact: 'Xavier.claraz@sodexo.com'
    'Application Function': 'Notifications'
  }
  kind: 'functionapp,linux'
  properties: {
    enabled: true
    serverFarmId: appServicePlanId
    siteConfig: {
      numberOfWorkers: 1
      netFrameworkVersion: 'v4.0'
      linuxFxVersion: 'Java|11'
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: endpointList[i].name
        }
      ]
    }
    keyVaultReferenceIdentity: 'SystemAssigned'
    
  }}]

