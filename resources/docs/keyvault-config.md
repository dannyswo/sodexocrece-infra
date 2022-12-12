Key Vault Configuration
-----------------------

## Key Vault objects

Secrets:

* crececonsdx-sqldatabase-sqladminloginname
* crececonsdx-sqldatabase-sqladminloginpass
* crececonsdx-sqldatabase-aadadminloginname

Encryption Keys:

* crececonsdx-appsdatastorage-key

Certificates:

* crececonsdx-appgateway-cert-public
* crececonsdx-appgateway-cert-private

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

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out cert-frontend.crt \
  -keyout cert-frontend.key \
  -subj "//CN=app.sodexo.com"

openssl pkcs12 -export \
  -in cert-frontend.crt \
  -inkey cert-frontend.key \
  -passout pass:test \
  -out cert-frontend.pfx

openssl pkcs12 -export \
  -in cert-frontend.crt \
  -inkey cert-frontend.key \
  -out cert-frontend.pfx
```

## Import SSL certificate into Key Vault via Azure CLI

```
az keyvault certificate import --vault-name azmxks1qta775 --name crececonsdx-appgateway-cert-frontend --file cert-frontend.pfx
az keyvault certificate import --vault-name azmxks1qta775 --name crececonsdx-appgateway-cert-backend --file cert-backend.pfx
```

```
./src/scripts/import-keyvault-certificate.sh "azmxks1qta775" "crececonsdx-appgateway-cert-backend" "certificates/cert-backend.pfx"
.\src\scripts\import-keyvault-certificate.cmd "azmxks1qta775" "crececonsdx-appgateway-cert-backend" "certificates\cert-backend.pfx"
```

## Verify certificates are loaded in the Application Gateway

```
az network application-gateway root-cert list --resource-group RG-demo-sodexo-crece --gateway-name azmxwa1eae513
az network application-gateway ssl-cert list --resource-group RG-demo-sodexo-crece --gateway-name azmxwa1eae513
```