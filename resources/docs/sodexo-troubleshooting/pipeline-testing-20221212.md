## nslookup Private Endpoints (from AKS Subnet)

```
Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxdb1jjt985.privatelink.database.windows.net
Address:  10.169.88.70

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxks1zph479.privatelink.vaultcore.azure.net
Address:  10.169.88.71

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxcr1wzg838.privatelink.azurecr.io
Address:  10.169.88.72

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxcr1wzg838.eastus2.data.privatelink.azurecr.io
Address:  10.169.88.73

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxst1rdg355.privatelink.blob.core.windows.net
Address:  10.169.88.74

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
```

## nslookup Sodexo Connect (from AKS Subnet)

```
Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    part-0013.t-0009.fdv2-t-msedge.net

Addresses:  2620:1ec:4e:1::41
2620:1ec:4f:1::41
13.107.237.41
13.107.238.41
  
Aliases:  brs-ciam-oidc-dev2.sodexo.com
  azieaf1bde639.azurefd.net
  star-azurefd-prod.trafficmanager.net
  shed.dual-low.part-0013.t-0009.fdv2-t-msedge.net
```

## nslookup Azure Services (from AKS Subnet)

```
Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    monitor.azure.com

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    oms.opinsights.azure.com

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    blob.core.windows.net

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azure-api.net

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    apif4e310c677694046b334793fd0305d38tig6gjzltp2ntxjx5hm2a.centralus.cloudapp.azure.com
Address:  13.89.63.253
Aliases:  developer.azure-api.net
  apimgmttmdc59fxl58g4afil0x077yewlot7rygon5ih8abb63.trafficmanager.net
  developer-centralus-01.regional.azure-api.net
```

## ping Private Endpoints (from AKS Subnet)

```
Pinging 10.169.88.70 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.70:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.88.71 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.71:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.88.72 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.72:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.88.73 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.73:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.88.74 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.74:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.93.4 with 32 bytes of data:
Reply from 10.169.93.34: Destination host unreachable.
Reply from 10.169.93.34: Destination host unreachable.
Reply from 10.169.93.34: Destination host unreachable.
Reply from 10.169.93.34: Destination host unreachable.

Ping statistics for 10.169.93.4:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
```

## ping Sodexo Connect (from AKS Subnet)

```
Pinging 10.167.161.4 with 32 bytes of data:
Reply from 10.167.161.4: bytes=32 time=2ms TTL=63
Reply from 10.167.161.4: bytes=32 time=1ms TTL=63
Reply from 10.167.161.4: bytes=32 time=2ms TTL=63
Reply from 10.167.161.4: bytes=32 time=5ms TTL=63

Ping statistics for 10.167.161.4:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 1ms, Maximum = 5ms, Average = 2ms
```

## nslookup Private Endpoints (from DevOps Agents Subnet)

```
Non-authoritative answer:

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxdb1jjt985.privatelink.database.windows.net
Address:  10.169.88.70

Non-authoritative answer:

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxks1zph479.privatelink.vaultcore.azure.net
Address:  10.169.88.71

Non-authoritative answer:

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxcr1wzg838.eastus2.data.privatelink.azurecr.io
Address:  10.169.88.73

Non-authoritative answer:

Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4
Name:    azmxst1rdg355.privatelink.blob.core.windows.net
Address:  10.169.88.74

*** usaz-ns1.sodexonet.com can't find azmxku1nlx625-89b09fdc.2ae8297e-5eff-45c7-a8f7-2b3472907333.privatelink.eastus2.azmk8s.io: Non-existent domain
Server:  usaz-ns1.sodexonet.com
Address:  10.167.161.4

```

## ping Private Endpoints (from DevOps Agents Subnet)

```
Pinging 10.169.88.70 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.70:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.88.71 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.71:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.88.72 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.72:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.88.73 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.73:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),
Pinging 10.169.88.74 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.88.74:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),

Pinging 10.169.93.4 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.

Ping statistics for 10.169.93.4:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),
```
