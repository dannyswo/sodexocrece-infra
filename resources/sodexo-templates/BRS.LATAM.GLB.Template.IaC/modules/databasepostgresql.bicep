

resource symbolicname 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: 'string'
  location: 'string'
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  sku: {
    capacity: 0
    family: 'string'
    name: 'string'
    size: 'string'
    tier: 'string'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    infrastructureEncryption: 'string'
    minimalTlsVersion: 'string'
    publicNetworkAccess: 'string'
    sslEnforcement: 'string'
    storageProfile: {
      backupRetentionDays: 0
      geoRedundantBackup: 'string'
      storageAutogrow: 'string'
      storageMB: 0
    }
    version: 'string'
    createMode: 'string'
    // For remaining properties, see ServerPropertiesForCreateOrServerProperties objects
  }
}
