Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Templates:

* main
* devopsmain

Modules (instances):

1. managedids
2. network1
3. monitoringdatastorage - RL01, MM03
4. loganalytics - RL02, MM01
5. networkwatcher - RL03, MM02
6. keyvault, keyvaultpe, keyvaultobjects, keyvaultpolicies - RL04, MM04
7. agw - RL05, MM05, AD01
8. appsdatastorage, appsdatastoragepe - RL06, MM06, AD02
10. sqldatabase, sqldatabasepe - RL07, MM07
11. acr, acrpe - RL08, MM08
12. aks - RL09

Environments:

* SoftwareONE: SWO
* Sodexo: DEV, UAT, PRD

Stacks and modules instances (experimental):

1. iam: managedids, users
2. network: network1
3. monitoring: monitoringdatastorage, loganalytics, networkwatcher
4. security: keyvault, keyvaultpe, keyvaultobjects, keyvaultpolicies
5. databases: appsdatastorage, appsdatastoragepe, sqldatabase, sqldatabasepe
6. frontend: agw, acr, acrpe, aks

## Useful Azure CLI Commands

Install and setup Bicep:

```
az bicep install
az bicep upgrade
az bicep version
az login
az bicep decompile --file .\template.json

az account show
az account set --subscription [Subscription ID]
az account list-locations -o table
az ad signed-in-user show
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