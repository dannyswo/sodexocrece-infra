Deployment Commands
-------------------

## Deployment commands

```
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\keyvault.bicep -p .\src\config\swo\keyvault.swo.json
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\modules\acr.bicep -p .\src\config\swo\acr.swo.json

az deployment group list --resource-group RG-demo-sodexo-crece --filter "provisioningState eq 'Failed'"

az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main1.bicep -p .\src\config\swo\main.swo.json
```