Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Templates and Modules:

landingzone/mainLandingZone (optional, only for SWO environments)

1. **networkModule** (network1): VNets and Subnets, Peerings, NSGs, custom Route Table for AKS, only for SWO environment.

shared/mainShared

1. **sharedUsersModule** (sharedUsers): Principals IDs of administrator Users / Groups (if necessary).
2. **adminUsersRgRbacModule** (adminUsersRgRbac): Role Assignments for administrators under Resource Group scope.
3. **managedIdsModule** (managedIds): Managed Identities of infrastructure services and applications.
4. **managedIdsRgRbacModule** (managedIdsRgRbac): Role Assignments for infrastructure services and applications under Resource Group scope.
5. **monitoringDataStorageModule** (monitoringDataStorage): Storage Account for monitoring data, used by networkWatcher and monitoringWorkspace. \[RL01\]
6. **monitoringDataStorageContainersModule** (monitoringDataStorageContainers): Containers of the monitoring data Storage Account. \[RL01\]
7. **monitoringWorkspaceModule** (monitoringWorkspace): Workspace for logs and metrics collection and analysis, used by keyvault, agw, appsdatastorage, sqldatabase, acr, aks. \[RL02, MM01\]
8. **infraKeyVaultModule** (infraKeyVault): Key Vault for infrastructure services and applications. \[RL04, MM04\]
9. **infraKeyVaultPrivateEndpointModule** (privateEndpoint): Private Endpoint, Private DNS Zone and VNet Links.
10. **infraKeyVaultObjectsModule** (infraKeyVaultObjects): creates Encryption Keys and Secrets for infrastructure services.
11. **infraKeyVaultPoliciesModule** (infraKeyVaultPolicies): configures Key Vault Access Policies for applications or users.
12. **infraKeyVaultRbac** (infraKeyVaultRbac): Role Assignments for users, infrastructure services and applications under Key Vault scope.
13. **flowLogsModule** (flowLogs): exports flow logs caputred for the Apps NSG in the monitoring data Storage Account. \[RL03, MM02, MM03\]
14. **serviceEndpointPoliciesModule** (serviceEndpointPolicies): creates Service Endpoint Policies for infrastructure Key Vault and monitoring data Storage Account (if necessary).

system/mainSystem

1. **systemUsersModule** (systemUsers): Principals IDs of project team Users / Groups (if neccessary).
3. **systemRgRbacModule** (systemRgRbac): Role Assignments for team Users / Groups under Resource Group scope (if necessary).
3. **appGatewayModule** (agw): Application Gateway, WAF Policies. \[RL05, MM05, AD01\]
4. **appsDataStorageModule** (appsDataStorage): Storage Account for applications data, Blob Container. [RL06, MM06, AD02\]
5. **appsDataStorageContainersModule** (appsDataStorageContainers): Containers of the applications data Storage Account.
6. **appsDataStoragePrivateEndpointModule** (privateEndpoint): Private Endpoint, Private DNS Zone and VNet Links.
7. **sqlDatabaseModule** (sqlDatabase): Azure SQL Server, SQL Database. \[RL07, MM07\]
8. **sqlDatabasePrivateEndpointModule** (privateEndpoint): Private Endpoint, Private DNS Zone and VNet Links.
9. **acrModule** (acr): Container Registry required by aks. \[RL08, MM08\]
10. **acrPrivateEndpointModule** (privateEndpoint): Private Endpoint, Private DNS Zone and VNet Links.
11. **aksModule** (aks): AKS Managed Cluster, custom Private DNS Zone. Depends on loganalytics, agw. \[RL09, AD03\]
12. **aksRbacModule** (aksRbac): Role Assignments for AKS under main Resource Group scope.
13. **aksNodeGroupRbacModule** (aksNodeGroupRbac): Role Assignments for AKS under AKS-managed Resource Group scope.

Environments:

* SoftwareONE: SWO
* Sodexo: DEV, UAT, PRD

## Technical auxiliary docs

Files in /resources/docs:

* az-cli-config.md: Installation and setup of Azure CLI and Bicep.
* deployment.md: Example deployment commands used to deployment the main templates in /src/templates.
* aks-config.md: Information about AKS Bicep properties, commands to connect to ACR with docker, commands to test AKS with kubectl and helm CLI tools.
* keyvault-config.md: Information about Key Vault certificate generation and import via Azure CLI.
* privateendpoint-config.md: Commands to get information about setup of Private Endpoints.
* sqldatabase-config.md: Commands to get information about Azure SQL Database tiers.
* networkwatcher-config.md: Commands to enable required providers by Network Watcher resource.
* loganalytics-config.md: Commands and Kusto queries to test logs in the monitoring Log Analytics Workspace.