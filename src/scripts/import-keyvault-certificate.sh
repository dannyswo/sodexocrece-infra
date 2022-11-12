#/bin/bash -e
vaultname=$1
certname=$2
certfile=$3

az keyvault certificate import \
  --vault-name $vaultname \
  --name $certname \
  --file $certfile

versionedSecretId=$(az keyvault certificate show -n $certname --vault-name $vaultname --query "sid" -o tsv)
unversionedSecretId=$(echo $versionedSecretId | cut -d'/' -f-5)

json="{ \"Result\": \"$unversionedSecretId\" }"

echo $json > "$AZ_SCRIPTS_OUTPUT_PATH"