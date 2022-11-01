param location string
param networkInterface object
var numberOfInstances = 2

@allowed([
  'dev'
  'prod'
  'uat'
])
param environmentType string = 'uat'

resource VM 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(1, numberOfInstances): {
  name: 'UXUSAZ-SIDAPP${i}D'
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
    hardwareProfile: {
      vmSize: 'DS3_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'RedHat'
        offer: 'RHEL'
        sku: '7_9'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.netinterface[i]
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}]
