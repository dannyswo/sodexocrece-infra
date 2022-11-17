Log Analytics Workspace Configuration
-------------------------------------

## Workspace settings

Set disableLocalAuth=false to allow OMSAgent to connect to Log Analytics Workspace.


## Log Analytics queries

Audit events queries:

```
// Storage Account access logs:

StorageBlobLogs
| summarize AccessLogsPerAccount=count() by AccountName

// Key Vault audits:

AzureDiagnostics
| summarize AuditsPerResource=count() by Resource

// ACR access logs:

ContainerRegistryRepositoryEvents
| limit 10

ContainerRegistryLoginEvents
| limit 10

// App Gateway and ACR metrics:

AzureMetrics
| summarize MetricsPerResource=count() by Resource

// AKS containers stdout logs:

ContainerLog
| limit 10

KubePodInventory
| where Name contains "merchant-view"
```