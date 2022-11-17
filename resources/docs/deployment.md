Deployment Commands
-------------------

## Deployment of main templates

Deploy main templates in Javier's Subscription:

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\main.bicep -p .\src\config\main.swo2.json
```

Deploy main templates in Danny's Subscription:

```
az deployment sub create -l eastus2 -f .\src\templates\landingzone\groupProject.bicep -p .\src\config\group-project.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\landingzone\mainLandingZone.bicep -p .\src\config\main-landingzone.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\shared\mainShared.bicep -p .\src\config\main-shared.swo.json -p secrtsSqlDatabaseSqlAdminLoginName=svr123 -p secrtsSqlDatabaseSqlAdminLoginPass=svr101102S -p devopsAgentPrincipalId=

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\system\mainSystem.bicep -p .\src\config\main-system.swo.json
```

## Deployment of individual modules (for testing)

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\modules\inframanagedids.bicep -p .\resources\config-modules\swo\managedids.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\network1.bicep -p .\resources\config-modules\swo\network1.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\modules\monitoringdatastorage.bicep -p .\resources\config-modules\swo\monitoringdatastorage.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\modules\loganalytics.bicep -p .\resources\config-modules\swo\loganalytics.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\modules\networkwatcher.bicep -p .\resources\config-modules\swo\networkwatcher.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\appskeyvault.bicep -p .\resources\config-modules\swo\keyvault.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\privateendpoint.bicep -p .\resources\config-modules\swo\keyvaultpe.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\agw.bicep -p .\resources\config-modules\swo\agw.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\appsdatastorage.bicep -p .\resources\config-modules\swo\appsdatastorage.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\privateendpoint.bicep -p .\resources\config-modules\swo\appsdatastoragepe.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\sqldatabase.bicep -p .\resources\config-modules\swo\sqldatabase.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\privateendpoint.bicep -p .\resources\config-modules\swo\sqldatabasepe.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\acr.bicep -p .\resources\config-modules\swo\acr.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\privateendpoint.bicep -p .\resources\config-modules\swo\acrpe.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\aks.bicep -p .\resources\config-modules\swo\aks.swo.json
```

## Useful deployment commands

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

## Integration testing commands

```
az storage blob download --account-name azmxst1deh711 -c merchantfiles -n crecesdx-namespace.k8s.yaml --auth-mode login
```