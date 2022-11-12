@echo off
set vaultname=%1
set certname=%2
set certfile=%3

az keyvault certificate import --vault-name %vaultname% --name %certname% --file %certfile%
for /f "delims=" %%i in ('az keyvault certificate show -n %certname% --vault-name %vaultname% --query "sid" -o tsv') do set versionedSecretId=%%i

set json={ \"Result\": \"%versionedSecretId%\" }

echo %json% > %AZ_SCRIPTS_OUTPUT_PATH%