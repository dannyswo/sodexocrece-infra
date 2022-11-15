/**
 * Module: monitoringdatastorage-containers
 * Depends on: monitoringdatastorage
 * Used by: shared/mainShared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the monitoring data Storage Account.')
param monitoringDataStorageAccountName string

// ==================================== Resources ====================================

// ==================================== Containers ====================================

resource sqlServerAssessmentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'sqlserverassessments'
  parent: blobServices
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

// ==================================== Storage Account ====================================

resource monitoringDataStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: monitoringDataStorageAccountName
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' existing = {
  name: 'default'
  parent: monitoringDataStorageAccount
}

// ==================================== Outputs ====================================

@description('URI of the SQL Server assessments Container.')
output sqlServerAssessmentsContainerUri string = '${monitoringDataStorageAccount.properties.primaryEndpoints.blob}/${sqlServerAssessmentsContainer.name}'
