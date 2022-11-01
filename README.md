Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Template:

* main

Modules:

* network
* privateendpoint
* keyVault
* agw
* loganalytics
* networkwatcher
* storage
* database
* acr
* aks

Environments:

* SoftwareONE: SWO
* Sodexo: DEV, UAT, PRD

## Useful Azure CLI Commands

Install and setup Bicep:

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
az deployment sub what-if -l [Region name] -f [Bicep file] -p [Config file]
az deployment sub create -l eastus2 -f .\src\templates\group.bicep -p .\src\config\[env]\group.[env].json
az deployment sub create `
  -l eastus2 `
  -f .\src\templates\group.bicep `
  -p .\src\config\swo\group.swo.json `
  --mode Complete
```

Create resources at Resource Group level with Bicep:

```
az deployment group what-if -g [Resource Group name] -f [Bicep file] -p [Config file]
az deployment group create -g RG-demo-sodexo-crece -f .\src\templates\main.bicep -p .\src\config\[env]\main.[env].json
az deployment group create `
  -g RG-demo-sodexo-crece `
  -f .\src\templates\main.bicep `
  -p .\src\config\swo\main.swo.json `
  --mode Incremental

az deployment group list --resource-group [Resource Group name] --filter "provisioningState eq 'Failed'"
```

Delete Deployments, Resource Groups and individual resources:

```
az deployment group delete -g [Resource Group name] -n [Deployment name]
az deployment group delete -g RG-demo-sodexo-crece -n main

az group delete -n [Resource Group name]

az resource delete `
  -g [Resource Group name] `
  -n [Resource name] `
  --resource-type [Resource type]
az resource delete `
  -g RG-demo-sodexo-crece `
  -n azmxcr1hle620 `
  --resource-type Microsoft.ContainerRegistry/registries
```