
param location string


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'azusku1bss410'
  location: location
  tags: {
    Stack: 'Alicanto'
    ApplicationName: 'BRS.LATAM.CL.Alicanto'
    ApplicationOwner: 'ignacio.zamorano@sodexo.com'
    ApplicationSponsor: 'david.dussart@sodexo.com'
    Billing: '{"BSD":"2021-10-14T14:00:00","CC":"2531","D":"","LE":"Sodexo Pass International SAS","MUP":""}'
    environmentType: 'DEV'
    Maintenance: '{ "InternalAssetIdentifier":"", "Provider":"SoftwareONE", "ProviderAssetIdentifier";"", "MaintenanceWindow":"TBD", "ServiceLevel":"TBD" }'
    Security: '{"C":4,"I":4,"A":4,"ITCritical":1,"BusCritical":1,"Situation":"Exposed","DJ":0,"ITOps":"SoftwareONE","SecOps":"GISS","hasPD":1,"Scope":"Local","DRP":1}'
    TechnicalContact: 'Xavier.claraz@sodexo.com'
  }
}
