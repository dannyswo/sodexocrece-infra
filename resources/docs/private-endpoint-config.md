Private Endpoint Bicep Configurations
-------------------------------------

## Check GroupID and MemberName of target resources

```
az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azusks1mat327 `
  --type Microsoft.KeyVault/vaults

az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azuscr1hle620 `
  --type Microsoft.ContainerRegistry/registries

az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azusst1ifv691 `
  --type Microsoft.Storage/storageAccounts

az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azusdb1mjx885 `
  --type Microsoft.Sql/servers
```

## Check environment URIs

```
az cloud list > .\resources\docs\az-cloud-list.json
```