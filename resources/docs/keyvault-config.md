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
  -out cert-private.crt \
  -keyout cert-private.key \
  -subj "//CN=test"

openssl pkcs12 -export \
  -in cert-private.crt \
  -inkey cert-private.key \
  -out cert-private.pfx

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -out cert-public.crt \
  -keyout cert-public.key \
  -subj "//CN=test"

openssl pkcs12 -export \
  -in cert-public.crt \
  -inkey cert-public.key \
  -passout pass:test \
  -out cert-public.pfx
```

## Import SSL certificate into Key Vault via Azure CLI

```
az keyvault certificate import \
  --vault-name azmxkv1mat350 \
  --name crececonsdx-appgateway-cert-private \
  --file cert-private.pfx
```