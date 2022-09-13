@maxLength(15)
param vmName string
param location string
param vNetName string
param sNetName string

@allowed([
  'Standard_B1s'
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_B4ms'
  'Standard_D2s_v5'
  'Standard_D4s_v5'
  'Standard_NV12s_v3'
  'Standard_NV32as_v4'
  'Standard_NV36ads_A10_v5'
])
param vmSize string = 'Standard_D2s_v5'

@allowed([
  'Standard_LRS' // HDD
  'StandardSSD_LRS' // SSD
  'Premium_LRS' // Premium SSD
])
param vmOSDiskStorageAccountType string = 'Premium_LRS'

param adminUsername string

@minLength(12)
@secure()
param adminPassword string

@allowed([
  'MicrosoftWindowsDesktop'
  'MicrosoftWindowsServer'
])
param vmImagePublisher string = 'MicrosoftWindowsDesktop'

@allowed([
  'Windows-10'
  'WindowsServer'
  'Office-365'
])
param vmImageOffer string = 'Office-365'

@allowed([
  '2019-datacenter-gensecond'
  'win10-21h2-pro'
  'win11-21h2-avd-m365'
])
param vmImageSku string = 'win11-21h2-avd-m365'

@allowed([
  'Windows_Client'
  'Windows_Server'
  'RHEL_BYOS' // for RHEL
  'SLES_BYOS' // for SUSE
])
param osAHBLicenseType string = 'Windows_Client'

param autoShutDown bool = true
param autoShutDownNoticeEmail string

@allowed([
  'None'
  'AD'
  'AAD'
])
param networkJoin string = 'None'
param domainToJoin string = ''
@description('Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) & NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx')
param domainJoinOptions int = 3
param domainOUPath string = ''
param domainUserName string = ''
@secure()
param domainPassword string = ''

param hostPoolName string = ''
param hostPoolRegToken string = ''

// =============================================================================================


var gpuNVIDIA = vmSize == 'Standard_NV12s_v3' || vmSize == 'Standard_NV36ads_A10_v5'
var gpuAMD = vmSize == 'Standard_NV32as_v4'
var installAVDAgent = hostPoolName != ''

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
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


// Run this if we are not Azure AD joining the session hosts
resource sessionHostDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (networkJoin == 'AD') {
  name: '${vmName}/JoinDomain'
  location: location
  dependsOn: [ vm ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: domainOUPath
      user: domainUserName
      options: domainJoinOptions
      restart: true
    }
    protectedSettings: {
      password: domainPassword
    }
  }
}

// Run this if we are Azure AD joining the session hosts - no intune support
resource sessionHostAADLogin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (networkJoin == 'AAD') {
  name: '${vmName}/AADLoginForWindows'
  location: location
  dependsOn: [ vm ]
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}


resource nvidiaDrivers 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (gpuNVIDIA) {
  name: 'NvidiaGpuDriverWindows' // ${vmName}/
  location: location
  parent: vm
  dependsOn: [ sessionHostDomainJoin, sessionHostAADLogin ]
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
    }
  }
}

resource amdDrivers 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (gpuAMD) {
  name: 'AmdGpuDriverWindows' // ${vmName}/
  location: location
  parent: vm
  dependsOn: [ sessionHostDomainJoin, sessionHostAADLogin ]
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'AmdGpuDriverWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    settings: {
    }
  }
}

//netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol="icmpv4:8,any" dir=in action=allow 
//netsh advfirewall firewall add rule name="ICMP Allow incoming V6 echo request" protocol="icmpv6:8,any" dir=in action=allow

resource enablePingIPv4 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'enable-ping-icmp-v4'
  location: location
  dependsOn: [ nvidiaDrivers, amdDrivers ]
  parent: vm
  properties: {
    source: {
      script: 'netsh advfirewall firewall add rule name="ICMPv4 Echo (Ping)" protocol="icmpv4:8,any" dir=in action=allow'
    }
  }
}

resource enablePingIPv6 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'enable-ping-icmp-v6'
  location: location
  dependsOn: [ nvidiaDrivers, amdDrivers ]
  parent: vm
  properties: {
    source: {
      script: 'netsh advfirewall firewall add rule name="ICMPv6 Echo (Ping)" protocol="icmpv6:8,any" dir=in action=allow'
    }
  }
}

resource shutdownSchedule 'Microsoft.DevTestLab/schedules@2018-09-15' = if (autoShutDown) {
  name: 'shutdown-computevm-${vmName}' // DO NOT change this name, it's required in this format only
  dependsOn: [ enablePingIPv4, enablePingIPv6 ]
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
      emailRecipient: autoShutDownNoticeEmail
    }
  }
}

resource sessionHostAVDAgent 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (installAVDAgent) {
  name: '${vmName}/AddSessionHost'
  location: location
  dependsOn: [ shutdownSchedule ]
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_08-10-2022.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolName
        registrationInfoToken: hostPoolRegToken
        aadJoin: (networkJoin == 'AAD')
        UseAgentDownloadEndpoint: true
      }
    }
  }
}

output id string = vm.id
output name string = vm.name
