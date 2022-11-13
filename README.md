Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Templates and Modules (instances):

shared/main

1. infraManagedIdsModule (inframanagedids): Managed Identities of infrastructure services and Role Assignments for them.
2. infraIamModule (infraiam): Role Assignments for DevOps, admin, system owner Users / Groups.
3. monitoringDataStorageModule (monitoringdatastorage): Storage Account for monitoring data, used by networkwatcher and loganalytics. [RL01, MM03]
4. logAnalyticsModule (loganalytics): Workspace for logs and metrics collection and analysis, used by keyvault, agw, appsdatastorage, sqldatabase, acr, aks. [RL02, MM01]
5. networkWatcherModule (networkwatcher): exports Flow Logs to monitoringdatastorage. [RL03, MM02]
6. infraKeyVaultModule (infrakeyvault): Key Vault for infrastructure services. [RL10, MM10]
7. infraKeyVaultObjectsModule (infrakeyvaultobjects): creation of Encryption Keys and Secrets, import of  Certificates.
8. infraKeyVaultPoliciesModule (infrakeyvaultpolicies): configures Key Vault Access Policies for Managed Identities and Users / Groups.

system/main

1. appsManagedIdsModule (appsmanagedids): Managed Identities of applications and Role Assignments for them.
2. appsIamModule (appsiam): Role Assignments for application developer Users / Groups.
3. networkModule (network1, optional): VNets and Subnets, Peerings, NSGs, custom Route Table for AKS, only for SWO environment.
4. appsKeyVaultModule (appskeyvault): Key Vault for applications. [RL04, MM04]
5. appsKeyVaultPrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
6. appsKeyVaultObjectsModule (appskeyvaultobjects): creation of Encryption Keys or Secrets for applications.
7. appsKeyVaultPoliciesModule (appskeyvaultpolicies): configures Key Vault Access Policies for Managed Identities and Users / Groups.
8. appGatewayModule (agw): Application Gateway, WAF Policies. [RL05, MM05, AD01]
9. appsDataStorageModule (appsdatastorage): Storage Account for applications data, Blob Container. [RL06, MM06, AD02]
10. appsDataStoragePrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
11. sqlDatabaseModule (sqldatabase): Azure SQL Server, SQL Database. [RL07, MM07]
12. sqlDatabasePrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
13. acrModule (acr): Container Registry required by aks. [RL08, MM08]
14. acrPrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
15. aksModule (aks): AKS Managed Cluster, custom Private DNS Zone and required Role Assignments. Depends on loganalytics, agw. [RL09, AD03]

Environments:

* SoftwareONE: SWO
* Sodexo: DEV, UAT, PRD

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