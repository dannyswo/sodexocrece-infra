Kubernetes Tests
----------------

## Testing AKS Pod-Managed Identity

Log of demo app:

```
 1 main.go:98] curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01": {"compute":{"location":"eastus2","name":"aks-agentpool1-97558103-vmss_0","offer":"","osType":"Linux","placementGroupId":"155f35c8-187b-4aa1-959b-8d500f5a6c58","platformFaultDomain":"0","platformUpdateDomain":"0","publisher":"","resourceGroupName":"MC_BRS-MEX-USE2-CRECESDX-SWO-RG01_BRS-MEX-USE2-CRECESDX-SWO-KU01_eastus2","sku":"","subscriptionId":"df6b3a66-4927-452d-bd5f-9abc9db8a9c0","tags":"AllowShutdown:True (for non-prod environments);ApplicationName:BRS.LATAM.MX.Crececonsdx;ApplicationOwner:luis.miranda@sodexo.com;ApplicationSponsor:javier.solano@sodexo.com;DeploymentDate:2022-11-15T0800 UTC (autogenatered);Env:dev;EnvironmentType:DEV;Maintenance:{ \"InternalAssetIdentifier\": \"\", \"Provider\": \"SoftwareONE\", \"ProviderAssetIdentifier\": \"\", \"MaintenanceWindow\": \"TBD\", \"ServiceLevel\": \"TBD\" };Security:{ \"C\": 4, \"I\": 4, \"A\": 4, \"ITCritical\": 1, \"BusCritical\": 1, \"Situation\": \"Exposed\", \"DJ\": 0, \"ITOps\": \"SoftwareONE\", \"SecOps\": \"GISS\", \"hasPD\": 1, \"Scope\": \"Local\", \"DRP\": 1 };TechnicalContact:xavier.claraz@sodexo.com;aks-managed-createOperationID:daa763ac-5eba-488e-b49a-e86fcf050f90;aks-managed-creationSource:vmssclient-aks-agentpool1-97558103-vmss;aks-managed-orchestrator:Kubernetes:1.23.12;aks-managed-poolName:agentpool1;aks-managed-resourceNameSuffix:42699380;aksAPIServerIPAddress:10.169.72.68;dd_organization:MX (only for prod environments);stack:Crececonsdx","version":"","vmId":"37f92c77-751f-4823-96ce-dd3fc86ed9ba","vmSize":"standard_d2s_v3"},"network":{"interface":[{"ipv4":{"ipAddress":[{"privateIpAddress":"10.169.72.69","publicIpAddress":""}],"subnet":[{"address":"10.169.72.64","prefix":"27"}]},"ipv6":{"ipAddress":[]},"macAddress":"6045BD82F3BF"}]}}
I1116 16:31:07.334019       1 main.go:70] successfully acquired a service principal token from IMDS using a user-assigned identity (3928003f-a34d-4601-b609-c3a96e87791b)
I1116 16:31:07.334072       1 main.go:43] Try decoding your token eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuYXp1cmUuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzFkYzliMzM5LWZhZGItNDMyZS04NmRmLTQyM2MzOGEwZmNiOC8iLCJpYXQiOjE2Njg2MTU5NjcsIm5iZiI6MTY2ODYxNTk2NywiZXhwIjoxNjY4NzAyNjY3LCJhaW8iOiJFMlpnWUFpU0Y3dlRLS0ZueDhhOTZqTmY2OEVUQUE9PSIsImFwcGlkIjoiMzkyODAwM2YtYTM0ZC00NjAxLWI2MDktYzNhOTZlODc3OTFiIiwiYXBwaWRhY3IiOiIyIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvMWRjOWIzMzktZmFkYi00MzJlLTg2ZGYtNDIzYzM4YTBmY2I4LyIsImlkdHlwIjoiYXBwIiwib2lkIjoiYzJlMmRjMjYtOGFhYy00YzVhLTg3MzktMmVkMzlkOGFmZTMyIiwicmgiOiIwLkFWd0FPYlBKSGR2NkxrT0czMEk4T0tEOHVFWklmM2tBdXRkUHVrUGF3ZmoyTUJOY0FBQS4iLCJzdWIiOiJjMmUyZGMyNi04YWFjLTRjNWEtODczOS0yZWQzOWQ4YWZlMzIiLCJ0aWQiOiIxZGM5YjMzOS1mYWRiLTQzMmUtODZkZi00MjNjMzhhMGZjYjgiLCJ1dGkiOiJrdWlDMnhza2JFYW9sOWZZbnVWTUFBIiwidmVyIjoiMS4wIiwieG1zX21pcmlkIjoiL3N1YnNjcmlwdGlvbnMvZGY2YjNhNjYtNDkyNy00NTJkLWJkNWYtOWFiYzlkYjhhOWMwL3Jlc291cmNlZ3JvdXBzL0JSUy1NRVgtVVNFMi1DUkVDRVNEWC1TV08tUkcwMS9wcm92aWRlcnMvTWljcm9zb2Z0Lk1hbmFnZWRJZGVudGl0eS91c2VyQXNzaWduZWRJZGVudGl0aWVzL0JSUy1NRVgtVVNFMi1DUkVDRVNEWC1TV08tQUQwNCIsInhtc190Y2R0IjoiMTQzOTk2OTQxNSJ9.DncRK4IJOGcW0kLveWpGSyVB3XeAdht9LFfKA6VOyFW8gnrZkn2pr5kEoQJRPvjsJo5gSac00t40cMu2Alyozmjxy4OtDB7mYLFSK6t0OrQuYDgwz-zWNlfCKzPkNkDNCBzvwIT_79ZoZJgiQFRp66bvCoYtRv3kul7F4amXfUjPxA3llBv5LKhMxiTMzYhr6N8NZLae21Yk5WFYlQkgOd7XiB49UFNbTYiFiZa0cXDKMt25PxoQGYbLuRgvNT36UiA9iAFQCQehXlHaHKTrYOVEkXbzLgiMQsdt6Tiy2RqUPbKtGr_rlugEXFYES_iDG3ofy6oZvNlTTonjRuLMsA at https://jwt.io
```

Token content from jwt.io:

```
{
  "aud": "https://management.azure.com/",
  "iss": "https://sts.windows.net/1dc9b339-fadb-432e-86df-423c38a0fcb8/",
  "iat": 1668615967,
  "nbf": 1668615967,
  "exp": 1668702667,
  "aio": "E2ZgYAiSF7vTKKFnx8a96jNf68ETAA==",
  "appid": "3928003f-a34d-4601-b609-c3a96e87791b",
  "appidacr": "2",
  "idp": "https://sts.windows.net/1dc9b339-fadb-432e-86df-423c38a0fcb8/",
  "idtyp": "app",
  "oid": "c2e2dc26-8aac-4c5a-8739-2ed39d8afe32",
  "rh": "0.AVwAObPJHdv6LkOG30I8OKD8uEZIf3kAutdPukPawfj2MBNcAAA.",
  "sub": "c2e2dc26-8aac-4c5a-8739-2ed39d8afe32",
  "tid": "1dc9b339-fadb-432e-86df-423c38a0fcb8",
  "uti": "kuiC2xskbEaol9fYnuVMAA",
  "ver": "1.0",
  "xms_mirid": "/subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourcegroups/BRS-MEX-USE2-CRECESDX-SWO-RG01/providers/Microsoft.ManagedIdentity/userAssignedIdentities/BRS-MEX-USE2-CRECESDX-SWO-AD04",
  "xms_tcdt": "1439969415"
}
```