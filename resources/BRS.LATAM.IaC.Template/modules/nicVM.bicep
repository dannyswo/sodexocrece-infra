param ENVConfiguration object
param location string
param Lbname string
param loadBalancerBackEndName string
var numberOfInstances = 2


@allowed([
  'dev'
  'prod'
  'uat'
])
param environmentType string = 'uat'

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(1, numberOfInstances): { 
  name: 'nic${i}'
  location: location
  tags: {
    ApplicationName:	'BRS.LATAM.MX.SID'
    ApplicationOwner:	'Ignacio.Zamorano@sodexo.com'
    Sponsor:	'Javier.solano@sodexo.com'
    Env:	environmentType
    EnvironmentType: environmentType
    DeploymentDate:	'YYYY-MM-DDTHHMM UTC'
    Security:	'{"C":3,"I":2,"A":3,"ITCritical":1,"BusCritical":1,"Situation":"Internal","DJ":1,"ITOps":"SoftwareONE","SecOps":"GISS","hasPD":1,"Scope":"Local","DRP":1}'
    TechnicalContact: 	'Xavier.claraz@sodexo.com'
    Maintenance:	'{ "InternalAssetIdentifier":"", "Provider":"SoftwareONE", "ProviderAssetIdentifier";"", "MaintenanceWindow":"TBD", "ServiceLevel":"TBD" }'
    AllowShutdown:	'True'
    Stack: 'Integration Services'
    Maintainer: 'SoftwareONE'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'UXUSAZ-SIDAPP${i}Pp752_z1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: ENVConfiguration[environmentType].subnet
          }
          loadBalancerBackendAddressPools:[
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', Lbname, loadBalancerBackEndName)
            }
          ]
        }
      }
    ]
  }
}]
output networkInterface_id object = {
  netinterface1: networkInterface[1].id
  netinterface2: networkInterface[2].id
}
  


