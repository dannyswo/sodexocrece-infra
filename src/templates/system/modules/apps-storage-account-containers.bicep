/**
 * Module: apps-storage-account-containers
 * Depends on: apps-storage-account
 * Used by: system/main-system
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the applications Storage Account.')
param appsStorageAccountName string

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

resource appsStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: appsStorageAccountName
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' existing = {
  name: 'default'
  parent: appsStorageAccount
}

// ==================================== Outputs ====================================

@description('URI of the merchant files Container.')
output merchantFilesContainerUri string = '${appsStorageAccount.properties.primaryEndpoints.blob}${merchantFilesContainer.name}'
