/**
 * Module: appsDataStorageContainers
 * Depends on: appsDataStorage
 * Used by: system/mainSystem
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the applications data Storage Account.')
param appsDataStorageAccountName string

// ==================================== Resources ====================================

// ==================================== Containers ====================================

resource merchantFilesContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'merchant-files'
  parent: blobServices
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

// ==================================== Stoarge Account ====================================

resource appsDataStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: appsDataStorageAccountName
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' existing = {
  name: 'default'
  parent: appsDataStorageAccount
}

// ==================================== Outputs ====================================

@description('URI of the merchant files Container.')
output merchantFilesContainerUri string = '${appsDataStorageAccount.properties.primaryEndpoints.blob}${merchantFilesContainer.name}'
