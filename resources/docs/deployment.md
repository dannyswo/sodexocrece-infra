Deployment Commands
-------------------

## Deployment commands

Deploy main templates in Javier's Subscription:

```
az deployment group list --resource-group RG-demo-sodexo-crece --filter "provisioningState eq 'Failed'"

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main1.bicep -p .\src\config\swo\main1.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main2.bicep -p .\src\config\swo\main2.swo.json
```

Deploy main templates in Danny's Subscription:

```
az deployment sub create -l eastus2 -f .\src\templates\group.bicep -p .\src\config\swo\group.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\main2.bicep -p .\src\config\swo\main2.swo.json
```

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\network1.bicep -p .\src\config\swo\network1.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\keyvault.bicep -p .\src\config\swo\keyvault.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\keyvaultpe.bicep -p .\src\config\swo\keyvaultpe.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\acr.bicep -p .\src\config\swo\acr.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\monitoringdatastorage.bicep -p .\src\config\swo\monitoringdatastorage.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\loganalytics.bicep -p .\src\config\swo\loganalytics.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\networkwatcher.bicep -p .\src\config\swo\networkwatcher.swo.json
```

Switch between Subscriptions:

```
// Javier's Subscription:
az account set --subscription f493167c-c1a8-4a50-9c6b-41b9a478f240

// Danny's Subscription:
az account set --subscription df6b3a66-4927-452d-bd5f-9abc9db8a9c0
```