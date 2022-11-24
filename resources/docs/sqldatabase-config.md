Azure SQL Database Configuration
--------------------------------

## Check Azure SQL Database SKUs available in a region

```
az sql db list-editions -l eastus2 -o table
az sql db list-editions -l eastus2 > .\resources\docs\az-sqldb-editions.json
```

## Send queries to Azure SQL Database with sqlcmd CLI

```
sqlcmd -S [server-name] -U [user-name] -P [user-password]
sqlcmd -S azmxdb1nkt895.database.windows.net -U [user-name] -P [user-password]

> SELECT * FROM sys.schemas
> GO

sqlcmd -S [server-name] -U [user-name] -P [user-password] -Q [sql-query]
sqlcmd -S azmxdb1nkt895.database.windows.net -U [user-name] -P [user-password] -Q "SELECT * FROM sys.schemas"
```