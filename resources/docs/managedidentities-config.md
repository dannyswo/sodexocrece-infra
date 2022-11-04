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