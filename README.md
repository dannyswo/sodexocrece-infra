Infrastructure Repository for Sodexo Crece Project
--------------------------------------------------

## Project structure

Templates and Modules:

landing-zone/main-landing-zone (optional, only for SWO environments)

1. **network-module** (network): VNets and Subnets, Peerings, NSGs, custom Route Table for AKS, only for SWO environment.

shared/main-shared

1. **users-rbac-module** (users-rbac): Role Assignments for administrators under Resource Group scope.
2. **managed-identities-module** (managed-identities): Managed Identities of infrastructure services and applications.
3. **managed-identities-rbac-module** (managed-identities-rbac): Role Assignments for infrastructure services and applications under Resource Group scope.
4. **monitoring-storage-account-module** (monitoring-storage-account): Storage Account for monitoring data, used by networkWatcher and monitoringWorkspace. \[RL01\]
5. **monitoring-storage-account-containers-module** (monitoring-storage-account-containers): Containers of the monitoring Storage Account. \[RL01\]
6. **monitoring-loganalytics-workspace-module** (monitoring-loganalytics-workspace): Workspace for logs and metrics collection and analysis, used by keyvault, agw, appsdatastorage, sqldatabase, acr, aks. \[RL02, MM01\]
7. **keyvault-module** (keyvault): Key Vault for infrastructure services and applications. \[RL04, MM04\]
8. **keyvault-private-endpoint-module** (private-endpoint): Private Endpoint, Private DNS Zone and VNet Links.
9. **keyvault-objects-module** (keyvault-objects): creates Encryption Keys and Secrets for infrastructure services.
10. **keyvault-policies-module** (keyvault-policies): configures Key Vault Access Policies for applications or users.
11. **keyvault-rbac-module** (keyvault-rbac): Role Assignments for users, infrastructure services and applications under Key Vault scope.
12. **flowlogs-nsg-module** (flowlogs-nsg): Obtains reference of existing Network Security Group used to capture flow logs.
13. **flowlogs-module** (flowlogs): exports flow logs caputred for the Apps NSG in the monitoring Storage Account. \[RL03, MM02, MM03\]
14. **service-endpoint-policies-module** (service-endpoint-policies): creates Service Endpoint Policies for Key Vault and monitoring Storage Account (if necessary).

system/main-system

1. **app-gateway-module** (app-gateway): Application Gateway, WAF Policies. \[RL05, MM05, AD01\]
2. **apps-storage-account-module** (apps-storage-account): Storage Account for applications data, Blob Container. [RL06, MM06, AD02\]
3. **apps-storage-account-containers-module** (apps-storage-account-containers): Containers of the applications data Storage Account.
4. **apps-storage-account-private-endpoint-module** (private-endpoint): Private Endpoint, Private DNS Zone and VNet Links.
5. **sql-database-module** (sql-database): Azure SQL Server, SQL Database. \[RL07, MM07\]
6. **sql-database-private-endpoint-module** (private-endpoint): Private Endpoint, Private DNS Zone and VNet Links.
7. **acr-module** (acr): Container Registry required by aks. \[RL08, MM08\]
8. **acr-private-endpoint-module** (private-endpoint): Private Endpoint, Private DNS Zone and VNet Links.
9. **aks-module** (aks): AKS Managed Cluster, custom Private DNS Zone. Depends on loganalytics, agw. \[RL09, AD03\]
10. **aks-keyvault-rbac-module** (aks-keyvault-rbac): Access Policies setup for AKS Managed Identities.
11. **aks-rbac-module** (aks-rbac): Role Assignments for AKS Managed Identities under project Resource Group scope.
12. **aks-nodegroup-rbac-module** (aks-nodegroup-rbac): Role Assignments for AKS Managed Identities under AKS-managed Resource Group scope.

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