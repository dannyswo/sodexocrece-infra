Azure SQL Database Configuration
--------------------------------

## Check Azure SQL Database SKUs available in a region

```
az sql db list-editions -l eastus2 -o table
az sql db list-editions -l eastus2 > .\resources\docs\az-sqldb-editions.json
```