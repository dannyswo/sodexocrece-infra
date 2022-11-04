Deployment Commands
-------------------

## Deployment commands

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\network1.bicep -p .\src\config\swo\network1.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\keyvault.bicep -p .\src\config\swo\keyvault.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\keyvaultpe.bicep -p .\src\config\swo\keyvaultpe.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\acr.bicep -p .\src\config\swo\acr.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\monitoringdatastorage.bicep -p .\src\config\swo\monitoringdatastorage.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\loganalytics.bicep -p .\src\config\swo\loganalytics.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\networkwatcher.bicep -p .\src\config\swo\networkwatcher.swo.json

az deployment group list --resource-group RG-demo-sodexo-crece --filter "provisioningState eq 'Failed'"

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main1.bicep -p .\src\config\swo\main1.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main2.bicep -p .\src\config\swo\main2.swo.json
```