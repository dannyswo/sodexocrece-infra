Deployment Commands
-------------------

## Deployment commands

Deploy main templates in Javier's Subscription:

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main.bicep -p .\src\config\main.swo.json
```

Deploy main templates in Danny's Subscription:

```
az deployment sub create -l eastus2 -f .\src\templates\group.bicep -p .\src\config\swo\group.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\main.bicep -p .\src\config\main.swo.json
```

Deploy individual modules:

```
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\managedids.bicep -p .\src\config\swo\managedids.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\network1.bicep -p .\src\config\swo\network1.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\monitoringdatastorage.bicep -p .\src\config\swo\monitoringdatastorage.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\loganalytics.bicep -p .\src\config\swo\loganalytics.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\networkwatcher.bicep -p .\src\config\swo\networkwatcher.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\keyvault.bicep -p .\src\config\swo\keyvault.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\src\config\swo\keyvaultpe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\agw.bicep -p .\src\config\swo\agw.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\appsdatastorage.bicep -p .\src\config\swo\appsdatastorage.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\src\config\swo\appsdatastoragepe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\sqldatabase.bicep -p .\src\config\swo\sqldatabase.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\src\config\swo\sqldatabasepe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\acr.bicep -p .\src\config\swo\acr.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\src\config\swo\acrpe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\aks.bicep -p .\src\config\swo\aks.swo.json
```

Verify failed deployments:

```
az deployment group list --resource-group RG-demo-sodexo-crece --filter "provisioningState eq 'Failed'"
az deployment group list --resource-group BRS-MEX-USE2-CRECESDX-SWO-RG01 --filter "provisioningState eq 'Failed'"
```

Switch between Subscriptions:

```
// Javier's Subscription:
az account set --subscription f493167c-c1a8-4a50-9c6b-41b9a478f240

// Danny's Subscription:
az account set --subscription df6b3a66-4927-452d-bd5f-9abc9db8a9c0
```