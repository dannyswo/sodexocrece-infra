param location string

@allowed([
  'dev'
  'qa'
  'uat'
  'prod'
])
param environmentType string = 'dev'


resource appInsightsColorin 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appInsightsColorin${environmentType}'
  location: location
  kind: 'web'
  etag: 'string'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    RetentionInDays: 90
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output appInsightsConnectionString string = appInsightsColorin.properties.ConnectionString

output appInsightsInstrumentationKey string = appInsightsColorin.properties.InstrumentationKey
