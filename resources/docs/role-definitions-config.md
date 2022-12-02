Managed Identities Configuration
--------------------------------

## Azure Documentation

* [Azure RBAC Role Definitions list](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-definitions-list)
* [Azure RBAC Built-in Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)

## Check built-in Azure RBAC Role Definitions

```
az role definition list -o table --query '[].{roleName:roleName, description:description}'
az role definition list > .\resources\docs\az-role-definitions.json
```

## List and delete custom Role Definitions

```
// Role Assignments permissions over RG

az role assignment create --assignee 40c2e922-9fb6-4186-a53f-44439c85a9df --role "Kubernetes Cluster - Azure Arc Onboarding" --resource-group MC_RG-demo-sodexo-crece_BRS-MEX-USE2-CRECESDX-SWO-KU01_eastus2

az role assignment create --assignee 40c2e922-9fb6-4186-a53f-44439c85a9df --role "Role Based Access Control Administrator (Preview)" --resource-group MC_RG-demo-sodexo-crece_BRS-MEX-USE2-CRECESDX-SWO-KU01_eastus2

az role assignment create --assignee 40c2e922-9fb6-4186-a53f-44439c85a9df --role "Kubernetes Cluster - Azure Arc Onboarding" --resource-group RG-demo-sodexo-crece

az role assignment create --assignee 40c2e922-9fb6-4186-a53f-44439c85a9df --role "Kubernetes Cluster - Azure Arc Onboarding" --resource-group RG-demo-sodexo-crece

// Azure Features management permissions over RG

az role assignment create --assignee 40c2e922-9fb6-4186-a53f-44439c85a9df --role "Cognitive Services Contributor" --resource-group RG-demo-sodexo-crece

az role definition list --name "Application Gateway Administrator"
az role definition delete --name "Application Gateway Administrator" --scope /subscriptions/f493167c-c1a8-4a50-9c6b-41b9a478f240/resourceGroups/RG-demo-sodexo-crece
az role definition delete --name "Application Gateway Administrator" --scope /subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourceGroups/BRS-MEX-USE2-CRECESDX-SWO-RG01

az role definition list --name "Route Table Administrator"
az role definition delete --name "Route Table Administrator 3" --scope /subscriptions/f493167c-c1a8-4a50-9c6b-41b9a478f240/resourceGroups/MC_RG-demo-sodexo-crece_BRS-MEX-USE2-CRECESDX-SWO-KU01_eastus2
az role definition delete --name "Route Table Administrator" --scope /subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourceGroups/MC_BRS-MEX-USE2-CRECESDX-SWO-RG01_BRS-MEX-USE2-CRECESDX-SWO-KU01_eastus2
```