/**
 * Module: monitoring-storage-account-containers
 * Depends on: monitoring-storage-account
 * Used by: shared/main-shared
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Resource properties ====================================

@description('Name of the monitoring data Storage Account.')
param monitoringDataStorageAccountName string

// ==================================== Resources ====================================

// ==================================== Containers ====================================

resource vulnerabilityAssessmentContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'vulnerability-assessment'
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

@description('URI of the Container for SQL Server vulnerability assessments.')
output vulnerabilityAssessmentContainerUri string = '${monitoringDataStorageAccount.properties.primaryEndpoints.blob}${vulnerabilityAssessmentContainer.name}'
