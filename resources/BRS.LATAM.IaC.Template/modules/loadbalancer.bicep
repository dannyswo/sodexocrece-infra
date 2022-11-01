param location string
param ENVConfiguration object
param lbname string = 'BRS-MEX-USE2-SID-UAT-ILB01'
param loadBalancerFrontEndName string = 'MEX-ILBFrontIP'
param loadBalancerBackEndName string = 'MEX-DYNMS-BACK'
param loadBalancerProbeName string = 'TCP-443'

@allowed([
  'dev'
  'prod'
  'uat'
])
param environmentType string = 'uat'

resource loadBalancerInternal 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: lbname
  location: location
  sku: {
    name:'Standard'
    tier:'Regional'
  }
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
    frontendIPConfigurations: [
      {
        name: loadBalancerFrontEndName
        properties: {
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: ENVConfiguration[environmentType].subnet
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: loadBalancerBackEndName
      }
    ]
    loadBalancingRules: [
      {
        name: 'Lb-rules'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbname, loadBalancerFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbname, loadBalancerBackEndName)
          }
          protocol: 'tcp'
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbname, loadBalancerProbeName)
          }
        }
      }
    ]
    probes: [
      {
        name: loadBalancerProbeName
        properties: {
          protocol: 'tcp'
          port: 443
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}
output loadBalacer_id string = loadBalancerInternal.id
output Lbname string = lbname
output loadBalancerBackEndName string = loadBalancerBackEndName
