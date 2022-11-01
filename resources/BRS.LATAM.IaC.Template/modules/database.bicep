param location string

@secure()
param sqlServerAdministratorLogin string

@secure()
param sqlServerAdministratorLoginPassword string

@allowed([
  'dev'
  'qa'
  'uat'
  'prod'
])
param environmentType string = 'dev'

var sqlDatabaseSku = {
 dev: {
      sku: {
        name: 'Basic'
        capacity: 5
      }
 }
 prod: {
  sku: { name: 'B1', capacity: 1 }
 }
}


var sqlServerName = 'ssqla${environmentType}'
var sqlDatabaseName = 'Colorin-DataBse'


resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
   administratorLogin: sqlServerAdministratorLogin
   administratorLoginPassword: sqlServerAdministratorLoginPassword 
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: sqlDatabaseName
  location: location
  parent: sqlServer
  sku: sqlDatabaseSku[environmentType].sku
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}
