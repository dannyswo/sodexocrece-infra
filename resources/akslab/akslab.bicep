param location string = resourceGroup().location

var commonTags = {
  Organization: 'Sodexo'
  System: 'SodexoCrecer'
  Environment: 'SWO-DEV'
}

resource mainVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'sodexocrecer-vnet01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'sodexocrecer-subnet-gateway'
        properties: {
          addressPrefix: '10.10.0.0/20'
        }
      }
      {
        name: 'sodexocrecer-subnet-aks'
        properties: {
          addressPrefix: '10.10.16.0/20'
        }
      }
    ]
    enableDdosProtection: false
  }
  tags: commonTags
}

resource agwPublicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: 'sodexocrecer-pip01'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Global'
  }
  zones: [ '1', '2', '3' ]
  properties: {
    deleteOption: 'Detach'
  }
  tags: commonTags
}

resource appGateway 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: 'sodexocrecer-agw01'
  location: location
  zones: [ '1', '2', '3' ]
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
    gatewayIPConfigurations: [
      {
        properties: {
          subnet: mainVNet.properties.subnets[0]
        }
      }
    ]
    frontendIPConfigurations: [
      {
        properties: {
          publicIPAddress: agwPublicIP
        }
      }
    ]
  }
  tags: commonTags
}

resource aksLogsAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'sodexocrecer-workspace01'
  location: location
  properties: {
    sku: {
      name: 'Standard'
      capacityReservationLevel: 20
    }
    retentionInDays: 7
    workspaceCapping: {
      dailyQuotaGb: 5
    }
    publicNetworkAccessForQuery: 'Enabled'
    publicNetworkAccessForIngestion: 'Enabled'
    features: {
      disableLocalAuth: true
      enableDataExport: false
      immediatePurgeDataOn30Days: true
    }
  }
  tags: commonTags
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-07-01' = {
  name: 'sodexocrecer-aks01'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  properties: {
    kubernetesVersion: '1.23.12'
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        availabilityZones: [ '1', '2', '3' ]
        enableAutoScaling: true
        count: 1
        minCount: 1
        maxCount: 3
        vnetSubnetID: mainVNet.properties.subnets[1].id
        vmSize: 'standard_d2s_v3'
        osType: 'Linux'
        //osDiskSizeGB: 0
        //osDiskType: 'Managed'
        tags: {
          Application: 'MerchantPortal'
        }
        maxPods: 100
      }
    ]
    dnsPrefix: 'sodexo-aks-m326tj0aq5'
    publicNetworkAccess: 'Enabled'
    networkProfile: {
      networkPlugin: 'kubenet'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        enableMultipleStandardLoadBalancers: false
      }
      outboundType: 'loadBalancer'
    }
    addonProfiles: {
      ingressApplicationGateway: {
        enabled: true
        config: {
          applicationGatewayId: appGateway.id
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: aksLogsAnalyticsWorkspace.id
        }
      }
    }
    enableRBAC: true
  }
  tags: commonTags
}
