Deployment Commands
-------------------

## Deployment commands

Deploy main templates in Javier's Subscription:

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main.bicep -p .\resources\config-modules\main.swo2.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\devopsmain.bicep -p .\src\config\devopsmain.swo.json
```

Deploy main templates in Danny's Subscription:

```
az deployment sub create -l eastus2 -f .\src\templates\group.bicep -p .\resources\config-modules\swo\group.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\main.bicep -p .\resources\config-modules\main.swo2.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\devopsmain.bicep -p .\src\config\devopsmain.swo.json
```

Deploy individual modules:

```
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\managedids.bicep -p .\resources\config-modules\swo\managedids.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\network1.bicep -p .\resources\config-modules\swo\network1.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\monitoringdatastorage.bicep -p .\resources\config-modules\swo\monitoringdatastorage.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\loganalytics.bicep -p .\resources\config-modules\swo\loganalytics.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\networkwatcher.bicep -p .\resources\config-modules\swo\networkwatcher.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\keyvault.bicep -p .\resources\config-modules\swo\keyvault.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\resources\config-modules\swo\keyvaultpe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\agw.bicep -p .\resources\config-modules\swo\agw.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\appsdatastorage.bicep -p .\resources\config-modules\swo\appsdatastorage.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\resources\config-modules\swo\appsdatastoragepe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\sqldatabase.bicep -p .\resources\config-modules\swo\sqldatabase.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\resources\config-modules\swo\sqldatabasepe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\acr.bicep -p .\resources\config-modules\swo\acr.swo.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\privateendpoint.bicep -p .\resources\config-modules\swo\acrpe.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\modules\aks.bicep -p .\resources\config-modules\swo\aks.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\aks.bicep -p .\resources\config-modules\swo\aks.swo.json -p nodeResourceGroupName=RG-demo-sodexo-crece-03
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