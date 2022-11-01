param location string

param virtualNetworks_BRS_GLB_USE2_APPLICBACK_DEV_VN01_externalid string = '/subscriptions/f3888d08-b6b3-4f5d-b4f1-45c1fedec20c/resourceGroups/BRS-GLB-USE2-NTWRKBRS-DEV-RG01/providers/Microsoft.Network/virtualNetworks/BRS-GLB-USE2-APPLICBACK-DEV-VN01'


resource appServiceEnvirontment 'Microsoft.Web/hostingEnvironments@2022-03-01' = {
  name: 'azusap1ojd390'
  
  location: location
  tags: {
    ApplicationName: 'BRS.LATAM.CL.Alicanto'
    ApplicationOwner: 'ignacio.zamorano@sodexo.com'
    ApplicationSponsor: 'david.dussart@sodexo.com'
    Billing: '{"BSD":"2021-10-14T14:00:00","CC":"2531","D":"","LE":"Sodexo Pass International SAS","MUP":""}'
    environmentType: 'DEV'
    Maintenance: '{ "InternalAssetIdentifier":"", "Provider":"SoftwareONE", "ProviderAssetIdentifier";"", "MaintenanceWindow":"TBD", "ServiceLevel":"TBD" }'
    Security: '{"C":4,"I":4,"A":4,"ITCritical":1,"BusCritical":1,"Situation":"Exposed","DJ":0,"ITOps":"SoftwareONE","SecOps":"GISS","hasPD":1,"Scope":"Local","DRP":1}'
    stack: 'Alicanto'
    TechnicalContact: 'Xavier.claraz@sodexo.com'
  }
  kind: 'ASEV3'
  properties: {
    virtualNetwork: {
      id: '${virtualNetworks_BRS_GLB_USE2_APPLICBACK_DEV_VN01_externalid}/subnets/BRS-CHL-USE2-ALICANTOBACK-DEV-SN01'
    }
    internalLoadBalancingMode: 'Web, Publishing'
    multiSize: 'Standard_D2d_v4'
    ipsslAddressCount: 0
    dnsSuffix: 'azusap1ojd390.appserviceenvironment.net'
    frontEndScaleFactor: 15
    upgradePreference: 'None'
    dedicatedHostCount: 0
    zoneRedundant: false
    networkingConfiguration: {
    }
  }
}

resource multiRolePool 'Microsoft.Web/hostingEnvironments/multiRolePools@2022-03-01' = {
  name: 'default'
  properties: {
    workerSize: 'Standard_D2d_v4'
  }
  parent: appServiceEnvirontment
}
