Deployment Commands
-------------------

## Deployment of main templates

Deploy main templates in Javier's Subscription:

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\landing-zone\main-landing-zone.bicep -p .\src\config\main-landing-zone.swo.json -p jumpServerAdminUsername= -p jumpServerAdminPassword=

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\main-shared.bicep -p .\src\config\main-shared.swo.json -p secrtsSqlDatabaseSqlAdminLoginName= -p secrtsSqlDatabaseSqlAdminLoginPass=

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\main-system.bicep -p .\src\config\main-system.swo.json
```

Deploy main templates in Danny's Subscription:

```
az deployment sub create -l eastus2 -f .\src\templates\landing-zone\groupProject.bicep -p .\src\config\group-project.swo.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\landing-zone\main-landing-zone.bicep -p .\src\config\main-landing-zone.swo.json -p jumpServerAdminUsername= -p jumpServerAdminPassword=

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\shared\main-shared.bicep -p .\src\config\main-shared.swo2.json -p secrtsSqlDatabaseSqlAdminLoginName= -p secrtsSqlDatabaseSqlAdminLoginPass=

az deployment group create -g BRS-MEX-USE2-CRECESDX-SWO-RG01 -f .\src\templates\system\main-system.bicep -p .\src\config\main-system.swo2.json
```

## Deployment of individual modules (SWO)

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\landingzone\modules\network.bicep -p .\resources\config-modules\swo\network1.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\modules\monitoring-storage-account.bicep -p .\resources\config-modules\swo\monitoring-storage-account-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\modules\monitoring-loganalytics-workspace.bicep -p .\resources\config-modules\swo\monitoring-loganalytics-workspace.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\shared\modules\flowlogs.bicep -p .\resources\config-modules\swo\flowlogs-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\keyvault.bicep -p .\resources\config-modules\swo\keyvault-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\app-gateway.bicep -p .\resources\config-modules\swo\app-gateway-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\apps-storage-account.bicep -p .\resources\config-modules\swo\apps-storage-account-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\private-endpoint.bicep -p .\resources\config-modules\swo\apps-storage-account-private-endpoint-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\sql-database.bicep -p .\resources\config-modules\swo\sql-database-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\acr.bicep -p .\resources\config-modules\swo\acr-module.swo.json

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\system\modules\aks.bicep -p .\resources\config-modules\swo\aks-module.swo.json
```

## Deployment of individual modules (Sodexo)

```
az deployment group create -g BRS-MEX-USE2-CRECESDX-DEV-RG01 -f .\src\templates\system\modules\acr.bicep -p .\resources\config-modules\dev\acr-module.dev.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-DEV-RG01 -f .\src\templates\system\modules\private-endpoint.bicep -p .\resources\config-modules\dev\acr-private-endpoint-module.dev.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-DEV-RG01 -f .\src\templates\shared\modules\managed-identities.bicep -p .\resources\config-modules\dev\common-params.dev.json
az deployment group create -g BRS-MEX-USE2-CRECESDX-DEV-RG01 -f .\src\templates\system\modules\aks.bicep -p .\resources\config-modules\dev\aks-module.dev.json

az deployment group create -g BRS-MEX-USE2-CRECESDX-DEV-RG01 -f .\src\templates\system\modules\apps-storage-account.bicep -p .\resources\config-modules\dev\apps-storage-account-module.dev.json

az deployment group create -g BRS-GLB-USE2-NTWRKBRS-DEV-RG01 -f .\src\templates\system\modules\system-network-references.bicep -p .\resources\config-modules\dev\system-network-references-module.dev.json
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

// Sodexo BRS Non production Subscription:
az account set --subscription f3888d08-b6b3-4f5d-b4f1-45c1fedec20c
```

## Integration testing commands

```
az login

az keyvault certificate import --vault-name azusks1qta775 --name crececonsdx-appgateway-cert-frontend --file cert-frontend.pfx
az login --identity; az storage blob download --account-name azusst1deh711 -c merchant-files -n crecesdx-namespace.k8s.yaml --auth-mode login
sqlcmd -S azusdb1nkt895.database.windows.net -U [user-name] -P [user-password] -Q "SELECT * FROM sys.schemas"
```