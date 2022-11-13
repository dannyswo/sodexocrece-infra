Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Templates and Modules (instances):

shared/main

1. infraUsersModules (infrausers): Principals IDs of administrator Users / Groups.
2. infraManagedIdsModule (inframanagedids): Managed Identities of infrastructure services.
3. infraRgRbacModule (rg-rbac): Role Assignments for administrators / infrastructure services under Resource Group scope.
4. monitoringDataStorageModule (monitoringdatastorage): Storage Account for monitoring data, used by networkwatcher and loganalytics. [RL01, MM03]
5. logAnalyticsModule (loganalytics): Workspace for logs and metrics collection and analysis, used by keyvault, agw, appsdatastorage, sqldatabase, acr, aks. [RL02, MM01]
6. networkWatcherModule (networkwatcher): exports Flow Logs to monitoringdatastorage. [RL03, MM02]
7. infraKeyVaultModule (infrakeyvault): Key Vault for infrastructure services. [RL10, MM10]
8. infraKeyVaultObjectsModule (infrakeyvaultobjects): creation of Encryption Keys and Secrets, import of Certificates.
9. infraKeyVaultPoliciesModule (infrakeyvaultpolicies): configures Key Vault Access Policies for Managed Identities and Users / Groups.
10. infraKeyVaultRbac (infrakeyvault-rbac): Role Assignments under infrastructure Key Vault scope.

system/main

1. appsUsersModules (appsusers): Principals IDs of project team Users / Groups.
2. appsManagedIdsModule (appsmanagedids): Managed Identities of applications.
3. appsRgRbacModule (rg-rbac): Role Assignments for applications / team under Resource Group scope.
4. networkModule (network1, optional): VNets and Subnets, Peerings, NSGs, custom Route Table for AKS, only for SWO environment.
5. appsKeyVaultModule (appskeyvault): Key Vault for applications. [RL04, MM04]
6. appsKeyVaultPrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
7. appsKeyVaultObjectsModule (appskeyvaultobjects): creation of Encryption Keys or Secrets for applications.
8. appsKeyVaultPoliciesModule (appskeyvaultpolicies): configures Key Vault Access Policies for Managed Identities and Users / Groups.
9. appsKeyVaultRbac (appskeyvault-rbac): Role Assignments for applications / teams under applications Key Vault scope.
10. appGatewayModule (agw): Application Gateway, WAF Policies. [RL05, MM05, AD01]
11. appsDataStorageModule (appsdatastorage): Storage Account for applications data, Blob Container. [RL06, MM06, AD02]
12. appsDataStoragePrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
13. sqlDatabaseModule (sqldatabase): Azure SQL Server, SQL Database. [RL07, MM07]
14. sqlDatabasePrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
15. acrModule (acr): Container Registry required by aks. [RL08, MM08]
16. acrPrivateEndpointModule (privateendpoint, optional): Private Endpoints, Private DNS Zone and VNet Links.
17. aksModule (aks): AKS Managed Cluster, custom Private DNS Zone and required Role Assignments. Depends on loganalytics, agw. [RL09, AD03]

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