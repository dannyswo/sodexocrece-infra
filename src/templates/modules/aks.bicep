@description('The name of the Managed Cluster resource.')
param clusterName string = 'aks101cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v2'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string
param environment string = 'DEV'
param availabilityZones array = [
  '3'
]
param enableAutoScaling bool = true
param mode string = 'System'
param kubernetesVersion string = '1.23.12'
var businessLine = 'BRS'
var businessRegion = 'LATAM'
var cloudRegion = 'USE2'
var projectName = 'CRECESDX'
var cloudProviderPool = 'az'
var cloudRegionPool = 'mx'
var cloudServicePool = 'ku'
var randomStringPool = take(uniqueString(resourceGroup().id),3)

resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: '${businessLine}-${businessRegion}-${cloudRegion}-${projectName}-${environment}-KU01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: 'azmxku1vnq206'
    agentPoolProfiles: [
      {
        name: '${cloudProviderPool}${cloudRegionPool}${cloudServicePool}1${randomStringPool}206-nodepool-1'
        //type: missing type
        mode: mode
        availabilityZones: availabilityZones
        osType: 'Linux'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize  
        enableAutoScaling: enableAutoScaling
        //autoscale instances
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
