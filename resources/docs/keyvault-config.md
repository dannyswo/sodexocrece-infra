Key Vault Configuration
-----------------------

## Key Vault objects

Secrets:

* crececonsdx-sqldatabase-sqladminloginname
* crececonsdx-sqldatabase-sqladminloginpass

Encryption Keys:

* crececonsdx-appsdatastorage-key
* crececonsdx-acr-key
* crececonsdx-merchantportal-key

Certificates:

* crececonsdx-appgateway-cert-frontend
* crececonsdx-appgateway-cert-backend

## Generate SSL certificate with openssl

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out cert-backend.crt \
  -keyout cert-backend.key \
  -subj "//CN=app.sodexo.com"

openssl pkcs12 -export \
  -in cert-backend.crt \
  -inkey cert-backend.key \
  -out cert-backend.pfx

openssl pkcs12 -export \
  -in cert-backend.crt \
  -inkey cert-backend.key \
  -passout pass:test \
  -out cert-backend-pwd.pfx

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out cert-frontend.crt \
  -keyout cert-frontend.key \
  -subj "//CN=app.sodexo.com"

openssl pkcs12 -export \
  -in cert-frontend.crt \
  -inkey cert-frontend.key \
  -out cert-frontend.pfx

openssl pkcs12 -export \
  -in cert-frontend.crt \
  -inkey cert-frontend.key \
  -passout pass:test \
  -out cert-frontend-pwd.pfx
```

## Import SSL certificates into Key Vault via Azure CLI

```
az keyvault certificate import --vault-name azusks1qta778 --name crececonsdx-appgateway-cert-frontend --file cert-frontend.pfx
az keyvault certificate import --vault-name azusks1qta778 --name crececonsdx-appgateway-cert-frontend --password [pass] --file cert-frontend-pwd.pfx

az keyvault certificate import --vault-name azusks1qta778 --name crececonsdx-appgateway-cert-backend --file cert-backend.pfx
az keyvault certificate import --vault-name azusks1qta778 --name crececonsdx-appgateway-cert-backend --password [pass] --file cert-backend-pwd.pfx
```

```
./src/scripts/import-keyvault-certificate.sh "azusks1qta778" "crececonsdx-appgateway-cert-backend" "certificates/cert-backend.pfx"
.\src\scripts\import-keyvault-certificate.cmd "azusks1qta778" "crececonsdx-appgateway-cert-backend" "certificates\cert-backend.pfx"
```

## Verify certificates are loaded in the Application Gateway

```
az network application-gateway root-cert list --resource-group RG-demo-sodexo-crece --gateway-name azuswa1eae513
az network application-gateway ssl-cert list --resource-group RG-demo-sodexo-crece --gateway-name azuswa1eae513
```