param databaseAccounts_azbrdb1uqa534_name string = 'azbrdb1uqa534'
param virtualNetworks_brs_glb_use2_applicback_dev_vn01_externalid string = '/subscriptions/f3888d08-b6b3-4f5d-b4f1-45c1fedec20c/resourceGroups/brs-glb-use2-ntwrkbrs-dev-rg01/providers/Microsoft.Network/virtualNetworks/brs-glb-use2-applicback-dev-vn01'
 param location string

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: databaseAccounts_azbrdb1uqa534_name
  location: location
  kind: 'MongoDB'
  identity: {
    type: 'None'
  }
  tags: {
    defaultExperience: 'Azure Cosmos DB for MongoDB API'
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
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: true
    virtualNetworkRules: [
      {
        id: '${virtualNetworks_brs_glb_use2_applicback_dev_vn01_externalid}/subnets/brs-chl-use2-database-dev-sn01'
        ignoreMissingVNetServiceEndpoint: false
      }
    ]
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'FullFidelity'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    apiProperties: {
      serverVersion: '4.0'
    }
    locations: [
      {
        locationName: 'East US 2'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: [
      {
        name: 'EnableMongo'
      }
      {
        name: 'DisableRateLimitingResponses'
      }
    ]
    ipRules: [
      {
        ipAddressOrRange: '104.42.195.92'
      }
      {
        ipAddressOrRange: '40.76.54.131'
      }
      {
        ipAddressOrRange: '52.176.6.30'
      }
      {
        ipAddressOrRange: '52.169.50.45'
      }
      {
        ipAddressOrRange: '52.187.184.26'
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
    networkAclBypassResourceIds: []
    
  }
}
