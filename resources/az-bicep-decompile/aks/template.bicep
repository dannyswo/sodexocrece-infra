@description('The name of the Managed Cluster resource.')
param resourceName string

@description('The location of AKS resource.')
param location string

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The version of Kubernetes.')
param kubernetesVersion string = '1.7.7'

@description('Network plugin used for building Kubernetes network.')
@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string

@description('Boolean flag to turn on and off of RBAC.')
param enableRBAC bool = true

@description('Boolean flag to turn on and off of virtual machine scale sets')
param vmssNodePool bool = false

@description('Boolean flag to turn on and off of virtual machine scale sets')
param windowsProfile bool = false

@description('The name of the resource group containing agent pool nodes.')
param nodeResourceGroup string

@description('An array of AAD group object ids to give administrative access.')
param adminGroupObjectIDs array = []

@description('Enable or disable Azure RBAC.')
param azureRbac bool = false

@description('Enable or disable local accounts.')
param disableLocalAccounts bool = false

@description('Enable private network access to the Kubernetes cluster.')
param enablePrivateCluster bool = false

@description('Boolean flag to turn on and off http application routing.')
param enableHttpApplicationRouting bool = true

@description('Boolean flag to turn on and off Azure Policy addon.')
param enableAzurePolicy bool = false

@description('Boolean flag to turn on and off secret store CSI driver.')
param enableSecretStoreCSIDriver bool = false

@description('Boolean flag to turn on and off omsagent addon.')
param enableOmsAgent bool = true

@description('Specify the region for your OMS workspace.')
param workspaceRegion string = 'East US'

@description('Specify the name of the OMS workspace.')
param workspaceName string

@description('Specify the resource id of the OMS workspace.')
param omsWorkspaceId string

@description('Select the SKU for your workspace.')
@allowed([
  'free'
  'standalone'
  'pernode'
])
param omsSku string = 'standalone'

@description('Specify the name of the Azure Container Registry.')
param acrName string

@description('The name of the resource group the container registry is associated with.')
param acrResourceGroup string

@description('The unique id used in the role assignment of the kubernetes service to the container registry service. It is recommended to use the default value.')
param guidValue string = newGuid()

module SolutionDeployment_20221012003347 './nested_SolutionDeployment_20221012003347.bicep' = {
  name: 'SolutionDeployment-20221012003347'
  scope: resourceGroup(split(omsWorkspaceId, '/')[2], split(omsWorkspaceId, '/')[4])
  params: {
    workspaceRegion: workspaceRegion
    omsWorkspaceId: omsWorkspaceId
  }
  dependsOn: [
    WorkspaceDeployment_20221012003347
  ]
}

module WorkspaceDeployment_20221012003347 './nested_WorkspaceDeployment_20221012003347.bicep' = {
  name: 'WorkspaceDeployment-20221012003347'
  scope: resourceGroup(split(omsWorkspaceId, '/')[2], split(omsWorkspaceId, '/')[4])
  params: {
    workspaceRegion: workspaceRegion
    workspaceName: workspaceName
    omsSku: omsSku
  }
}

module ConnectAKStoACR_bfce7788_9e65_4017_a7da_c752b6448185 './nested_ConnectAKStoACR_bfce7788_9e65_4017_a7da_c752b6448185.bicep' = {
  name: 'ConnectAKStoACR-bfce7788-9e65-4017-a7da-c752b6448185'
  scope: resourceGroup(acrResourceGroup)
  params: {
    reference_parameters_resourceName_2022_06_01_identityProfile_kubeletidentity_objectId: reference(resourceName, '2022-06-01')
    resourceId_parameters_acrResourceGroup_Microsoft_ContainerRegistry_registries_parameters_acrName: resourceId(acrResourceGroup, 'Microsoft.ContainerRegistry/registries/', acrName)
    acrName: acrName
    guidValue: guidValue
  }
  dependsOn: [
    resource
    AcrDeployment_bfce7788_9e65_4017_a7da_c752b6448186
  ]
}

module AcrDeployment_bfce7788_9e65_4017_a7da_c752b6448186 './nested_AcrDeployment_bfce7788_9e65_4017_a7da_c752b6448186.bicep' = {
  name: 'AcrDeployment-bfce7788-9e65-4017-a7da-c752b6448186'
  scope: resourceGroup('df6b3a66-4927-452d-bd5f-9abc9db8a9c0', 'sodexocrecer-rg01')
  params: {
  }
}

resource resource 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  location: location
  name: resourceName
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: enableRBAC
    dnsPrefix: dnsPrefix
    nodeResourceGroup: nodeResourceGroup
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: 3
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        storageProfile: 'ManagedDisks'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeTaints: []
        enableNodePublicIP: false
        tags: {
          Organization: 'Sodexo'
          System: 'SodexoCrecer'
          Environment: 'SWODEV'
        }
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: networkPlugin
    }
    disableLocalAccounts: disableLocalAccounts
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: enableHttpApplicationRouting
      }
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      azureKeyvaultSecretsProvider: {
        enabled: enableSecretStoreCSIDriver
        config: null
      }
      omsAgent: {
        enabled: enableOmsAgent
        config: {
          logAnalyticsWorkspaceResourceID: omsWorkspaceId
        }
      }
    }
  }
  tags: {
    Organization: 'Sodexo'
    System: 'SodexoCrecer'
    Environment: 'SWODEV'
  }
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    WorkspaceDeployment_20221012003347
  ]
}

module ClusterMonitoringMetricPulisherRoleAssignmentDepl_20221012003347 './nested_ClusterMonitoringMetricPulisherRoleAssignmentDepl_20221012003347.bicep' = {
  name: 'ClusterMonitoringMetricPulisherRoleAssignmentDepl-20221012003347'
  scope: resourceGroup('df6b3a66-4927-452d-bd5f-9abc9db8a9c0', 'sodexocrecer-rg01')
  params: {
    reference_parameters_resourceName_addonProfiles_omsAgent_identity_objectId: resource.properties
  }
  dependsOn: [

    '/subscriptions/df6b3a66-4927-452d-bd5f-9abc9db8a9c0/resourceGroups/sodexocrecer-rg01/providers/Microsoft.ContainerService/managedClusters/sodexocrecer-aks01'
  ]
}

output controlPlaneFQDN string = resource.properties.privateFQDN