Log Analytics Workspace Configuration
-------------------------------------

## Workspace settings

Set disableLocalAuth=false to allow OMSAgent to connect to Log Analytics Workspace.


## Log Analytics queries

Audit events queries:

```
AzureDiagnostics
| summarize AuditEventsPerResource = count() by ResourceType
```