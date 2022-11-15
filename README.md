Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Templates and Modules:

landingzone/mainLandingZone (optional, only for SWO environments)

1. **networkModule** (network1): VNets and Subnets, Peerings, NSGs, custom Route Table for AKS, only for SWO environment.

shared/mainShared

1. **infraUsersModules** (infraUsers): Principals IDs of administrator Users / Groups.
2. **infraManagedIdsModule** (infraManagedIds): Managed Identities of infrastructure services.
3. **infraRgRbacModule** (infraRbRbac): Role Assignments for administrators / infrastructure services under Resource Group scope.
4. **monitoringDataStorageModule** (monitoringDataStorage): Storage Account for monitoring data, used by networkWatcher and monitoringWorkspace. \[RL01\]
5. **monitoringDataStorageContainersModule** (monitoringDataStorageContainers): Containers of the monitoring data Storage Account. \[RL01, MM03\]
6. **monitoringWorkspaceModule** (monitoringWorkspace): Workspace for logs and metrics collection and analysis, used by keyvault, agw, appsdatastorage, sqldatabase, acr, aks. \[RL02, MM01\]
7. **infraKeyVaultModule** (infraKeyVault): Key Vault for applications. \[RL04, MM04\]
8. **infraKeyVaultPrivateEndpointModule** (privateEndpoint): Private Endpoints, Private DNS Zone and VNet Links.
9. **infraKeyVaultObjectsModule** (infraKeyVaultObjects): creation of Encryption Keys or Secrets for applications.
10. **infraKeyVaultPoliciesModule** (infraKeyVaultPolicies): configures Key Vault Access Policies for Managed Identities and Users / Groups.
11. **infraKeyVaultRbac** (infraKeyVaultRbac): Role Assignments for applications / teams under applications Key Vault scope.

system/mainSystem

1. **teamUsersModules** (teamUsers): Principals IDs of project team Users / Groups.
2. **appsManagedIdsModule** (appsManagedIds): Managed Identities of applications.
3. **teamRgRbacModule** (teamRgRbac): Role Assignments for applications / team under Resource Group scope.
4. **networkWatcherModule** (networkWatcher): exports Flow Logs to monitoringdatastorage. \[RL03, MM02\]
5. **appGatewayModule** (agw): Application Gateway, WAF Policies. \[RL05, MM05, AD01\]
6. **appsDataStorageModule** (appsDataStorage): Storage Account for applications data, Blob Container. [RL06, MM06, AD02\]
7. **appsDataStorageContainersModule** (appsDataStorageContainers): Containers of the applications data Storage Account.
8. **appsDataStoragePrivateEndpointModule** (privateEndpoint): Private Endpoints, Private DNS Zone and VNet Links.
9. **sqlDatabaseModule** (sqlDatabase): Azure SQL Server, SQL Database. \[RL07, MM07\]
10. **sqlDatabasePrivateEndpointModule** (privateEndpoint): Private Endpoints, Private DNS Zone and VNet Links.
11. **acrModule** (acr): Container Registry required by aks. \[RL08, MM08\]
12. **acrPrivateEndpointModule** (privateEndpoint): Private Endpoints, Private DNS Zone and VNet Links.
13. **aksModule** (aks): AKS Managed Cluster, custom Private DNS Zone and required Role Assignments. Depends on loganalytics, agw. \[RL09, AD03\]

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