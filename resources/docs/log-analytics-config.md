
## Log Analytics Queries

### Audit events queries

```
AzureDiagnostics
| summarize AuditEventsPerResource = count() by ResourceType
```

Set disableLocalAuth=false to allow OMSAgent to connect to Log Analytics Workspace.