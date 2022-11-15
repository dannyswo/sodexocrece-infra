/**
 * Module: jumpServer
 * Depends on: N/A
 * Used by: landingzone/mainLandingZone
 * Common resources: N/A
 */

// ==================================== Parameters ====================================

// ==================================== Common parameters ====================================

@description('Azure region.')
param location string = resourceGroup().location

@description('Environment code.')
@allowed([
  'SWO'
  'DEV'
  'UAT'
  'PRD'
])
param env string

@description('Standards tags applied to all resources.')
param standardTags object

// ==================================== Resource properties ====================================

@secure()
param adminUsername string

@secure()
param adminPassword string

param jumpServersVNetName string

param jumpServersSubnetName string

param jumpServersNSGName string

// ==================================== Resources ====================================

// ==================================== VMs, NICs and Public IP Addresses ====================================

var jumpServer1Name = 'BRS-MEX-USE2-CRECESDX-${env}-VM01'
var jumpServer1ComputerName = 'RSUSAZ-SOOJMP2P'
var jumpServer1NICName = 'brs-mex-use2-crec592'
var jumpServer1DiskName = 'BRS-MEX-USE2-CRECESDX-${env}-ST01'

resource jumpServer1 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: jumpServer1Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      osDisk: {
        createOption: 'Attach'
        name: '${jumpServer1Name}-Disk-1'
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', jumpServer1DiskName)
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: 'win10-21h2-pro-g2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumpServer1NIC.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: jumpServer1ComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'AutomaticByOS'
        }
      }
    }
    licenseType: 'Windows_Client'
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  tags: standardTags
}

resource jumpServer1NIC 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: jumpServer1NICName
  location: location
  properties: {
    ipConfigurations: [
      {
        id: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', jumpServersVNetName, jumpServersSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: jumpServer1PublicIPAddress.id
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', jumpServersNSGName)
    }
  }
}

resource jumpServer1PublicIPAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: 'BRS-MEX-USE2-CRECESDX-${env}-IP30'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: standardTags
}

// ==================================== DevTestLab Schedules ====================================

resource jumpServer1Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: '${jumpServer1Name}-Shutdown-1'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '00:00'
    }
    timeZoneId: 'SA Pacific Standard Time'
    targetResourceId: jumpServer1.id
    notificationSettings: {
      status: 'Enabled'
      emailRecipient: 'danny.zamorano@softwareone.com'
      timeInMinutes: 30
      notificationLocale: 'en'
    }
  }
}
