Private Endpoint Bicep Configurations
-------------------------------------

## Check GroupID and MemberName of Key Vault

```
az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azmxkv1mat327 `
  --type Microsoft.KeyVault/vaults
```

```
[
  {
    "id": "/subscriptions/f493167c-c1a8-4a50-9c6b-41b9a478f240/resourceGroups/RG-demo-sodexo-crece/providers/Microsoft.KeyVault/vaults/azmxkv1mat327/privateLinkResources/vault",
    "name": "vault",
    "properties": {
      "groupId": "vault",
      "requiredMembers": [
        "default"
      ],
      "requiredZoneNames": [
        "privatelink.vaultcore.azure.net"
      ]
    },
    "resourceGroup": "RG-demo-sodexo-crece",
    "type": "Microsoft.KeyVault/vaults/privateLinkResources"
  }
]
```

## Check GroupID and MemberName of ACR

```
az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azmxcr1hle620 `
  --type Microsoft.ContainerRegistry/registries
```

```
[
  {
    "id": "/subscriptions/f493167c-c1a8-4a50-9c6b-41b9a478f240/resourceGroups/RG-demo-sodexo-crece/providers/Microsoft.ContainerRegistry/registries/azmxcr1hle620/privateLinkResources/registry",
    "name": "registry",
    "properties": {
      "groupId": "registry",
      "requiredMembers": [
        "registry_data_eastus2",
        "registry"
      ],
      "requiredZoneNames": [
        "privatelink.azurecr.io"
      ]
    },
    "resourceGroup": "RG-demo-sodexo-crece",
    "type": "Microsoft.ContainerRegistry/registries/privateLinkResources"
  }
]
```

## Check GroupID and MemberName of Storage Account

```
az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azmxst1ifv691 `
  --type Microsoft.Storage/storageAccounts
```

```
[
  {
  }
]
```

## Check GroupID and MemberName of Azure SQL Database

```
az network private-link-resource list `
  --resource-group RG-demo-sodexo-crece `
  --name azmxdb1mjx885 `
  --type Microsoft.Sql/servers
```

```
[
  {
  }
]
```