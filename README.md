# sodexocrecer-infra
Infrastructure resource in Bicep for SodexoCrecer project

## Commands

Install Bicep:

```
az bicep install
az bicep upgrade
az bicep version
az login
az bicep decompile --file .\template.json

az account set --subscription [Subscription ID]
az account list-locations -o table
```

Create resources at Subscription level with Bicep:

```
az deployment sub what-if -l [Region name] -f [Bicep file]
az deployment sub create -l [Region name] -f [Bicep file] -p [Param]=[Value]
az deployment sub create -l EastUS -f ./applications/backend/locations-processor-group.bicep -p ./config/environment.swodev.json
az deployment sub create \
  --location EastUS \
  --template-file ./applications/backend/locations-processor-group.bicep \
  --parameters Environment=SWO-Dev
```

Create resources at Resource Group level with Bicep:

```
az deployment group what-if -g [Resource Group name] -f [Bicep file]
az deployment group create -g [Resource Group name] -f [Bicep file] -p [Param]=[Value]
az deployment group create -g rg-gvdp-locationsprocessor-swodev-eastus -f ./applications/backend/locations-processor.bicep -p ./config/locations-processor.swodev.json --mode Complete
az deployment group create \
  -g rg-gvdp-locationsprocessor-swodev-eastus \
  -f ./applications/backend/locations-processor.bicep
  -p Environment SWO-Dev
  --mode Complete
```

Delete Deployment at Resource Group level and individual resources:

```
az deployment group delete -g [Resource Group name] -n [Deployment name]
az deployment group delete -g rg-gvdp-locationsprocessor-swodev-eastus -n locations-processor

az resource delete \
  -g rg-gvdp-locationsprocessor-swodev-eastus \
  -n asw-gvdp-locationsprocessor-swodev-eastus-sucadavdcchwi \
  --resource-type Microsoft.Web/sites

az group delete -n rg-gvdp-locationsprocessor-swodev-eastus
```