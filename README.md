Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Templates and Modules (instances):

devopsmain

1. devopsmanagedids: Managed Identities of infrastructure services and Role Assignments for them.
2. devopsiam: Role Assignments for DevOps, admin, system owner Users / Groups.

3. monitoringdatastorage - RL01, MM03: Storage Account for monitoring data, used by networkwatcher and loganalytics.
4. loganalytics - RL02, MM01: Workspace for logs and metrics collection and analysis, used by keyvault, agw, appsdatastorage, sqldatabase, acr, aks.
5. networkwatcher - RL03, MM02: exports Flow Logs to monitoringdatastorage.

3. devopskeyvault - RL10, MM10: Key Vault for infrastructure services.
4. devopskeyvaultobjects: creation of Encryption Keys and Secrets, import of  Certificates.
5. devopskeyvaultpolicies: configures Key Vault Access Policies for Managed Identities and Users / Groups.

main

1. managedids: Managed Identities of applications and Role Assignments for them.
2. iam: Role Assignments for application developer Users / Groups.
3. network1 (optional): VNets and Subnets, Peerings, NSGs, custom Route Table for AKS, only for SWO environment.
4. keyvault - RL04, MM04: Key Vault for applications.
5. keyvaultpe (optional): Private Endpoints, Private DNS Zone and VNet Links.
6. devopskeyvaultobjects: creation of Encryption Keys or Secrets for applications.
7. keyvaultpolicies: configures Key Vault Access Policies for Managed Identities and Users / Groups.
8. agw - RL05, MM05, AD01: Application Gateway, WAF Policies.
9. appsdatastorage - RL06, MM06, AD02: Storage Account for applications data, Blob Container.
10. appsdatastoragepe (optional): Private Endpoints, Private DNS Zone and VNet Links.
11. sqldatabase - RL07, MM07: Azure SQL Server, SQL Database.
12. sqldatabasepe (optional): Private Endpoints, Private DNS Zone and VNet Links.
13. acr - RL08, MM08: Container Registry required by aks.
14. acrpe (optional): Private Endpoints, Private DNS Zone and VNet Links.
15. aks - RL09: AKS Managed Cluster, custom Private DNS Zone and required Role Assignments. Depends on loganalytics, agw.

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
az bicep decompile --file .\template.json

az login
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