param vNetName string
param sNetName string

@maxLength(15)
param vmName string

param location string = resourceGroup().location

@allowed([
  'Standard_B1s'
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_B4ms'
  'Standard_D2s_v5'
  'Standard_D4s_v5'
])
param vmSize string = 'Standard_D2s_v5'

@allowed([
  'Standard_LRS' 
  'StandardSSD_LRS'
  'Premium_LRS'
])
param vmOSDiskStorageAccountType string = 'StandardSSD_LRS'

param adminUsername string = 'azureuser'

@minLength(12)
@secure()
param adminPassword string = 'MyPassword#1'

@allowed([
  'MicrosoftWindowsDesktop'
  'MicrosoftWindowsServer'
])
param vmImagePublisher string = 'MicrosoftWindowsDesktop'

@allowed([
  'Windows-10'
  'WindowsServer'
])
param vmImageOffer string = 'Windows-10'

@allowed([
  'win10-21h2-pro'
  '2019-datacenter-gensecond'
])
param vmImageSku string = 'win10-21h2-pro'

@allowed([
  'Windows_Client'
  'Windows_Server'
  'RHEL_BYOS' // for RHEL
  'SLES_BYOS' // for SUSE
])
param osAHBLicenseType string = 'Windows_Client'

param autoShutDown bool = true


resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: '${vmName}_nic'
  location: location
  properties: {
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    ipConfigurations: [
      {
        name: '${vmName}-nic-ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vNetName, sNetName)
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    storageProfile: {
      osDisk: {
        name: '${vmName}_osdisk'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: vmOSDiskStorageAccountType
        }
      }

      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: 'latest'
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }

    osProfile: {
      computerName: vmName
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

    licenseType: osAHBLicenseType
    
    //diagnosticsProfile: {
    //  bootDiagnostics: {
    //    enabled: false
    //  }
    //}
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource shutdownSchedule 'Microsoft.DevTestLab/schedules@2018-09-15' = if (autoShutDown) {
  name: 'shutdown-computevm-${vmName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '04:00'
    }
    timeZoneId: 'Pacific Standard Time'
    targetResourceId: vm.id
    notificationSettings: {
      status: 'Enabled'
      notificationLocale: 'en'
      timeInMinutes: 30
      emailRecipient: 'tubhi@microsoft.com'
    }
  }
}

output id string = vm.id
output name string = vm.name
