var params = loadJsonContent('../../params.json')

var primaryRG = resourceGroup(params.primaryRGName)

param deployPrimaryHubDMZVM bool = false
param deployPrimarySpoke1WorkloadVM bool = false
param deployPrimarySpoke2WorkloadVM bool = false

module primaryHubDMZVM './components/vm.bicep' = if (deployPrimaryHubDMZVM) {
  name: 'primaryHubDMZVMDeployment'
  scope: primaryRG
  params: {
    vNetName: params.primaryNetwork.hub.name
    sNetName: params.primaryNetwork.hub.dmzSubnetName
    location: params.primaryRGLocation
    vmName: 'pri-hub-vm1'
    vmSize: 'Standard_D2s_v5'
    vmOSDiskStorageAccountType: 'Premium_LRS'
    adminUsername: 'azureuser'
    adminPassword: 'MyPassword#1'
    vmImagePublisher: 'MicrosoftWindowsServer'
    vmImageOffer: 'WindowsServer'
    vmImageSku: '2019-datacenter-gensecond'
    osAHBLicenseType: 'Windows_Server'
    autoShutDown: true
  }
}

module primarySpoke1WorkloadVM './components/vm.bicep' = if (deployPrimarySpoke1WorkloadVM) {
  name: 'primarySpoke1WorkloadVMDeployment'
  scope: primaryRG
  params: {
    vNetName: params.primaryNetwork.spoke1.name
    sNetName: params.primaryNetwork.spoke1.workloadSubnetName
    location: params.primaryRGLocation
    vmName: 'pri-spoke1-vm1'
    vmSize: 'Standard_D2s_v5'
    vmOSDiskStorageAccountType: 'Premium_LRS'
    adminUsername: 'azureuser'
    adminPassword: 'MyPassword#1'
    vmImagePublisher: 'MicrosoftWindowsDesktop'
    vmImageOffer: 'Windows-10'
    vmImageSku: 'win10-21h2-pro'
    osAHBLicenseType: 'Windows_Client'
    autoShutDown: true
  }
}

module primarySpoke2WorkloadVM './components/vm.bicep' = if (deployPrimarySpoke2WorkloadVM) {
  name: 'primarySpoke2WorkloadVMDeployment'
  scope: primaryRG
  params: {
    vNetName: params.primaryNetwork.spoke2.name
    sNetName: params.primaryNetwork.spoke2.workloadSubnetName
    location: params.primaryRGLocation
    vmName: 'pri-spoke2-vm1'
    vmSize: 'Standard_D2s_v5'
    vmOSDiskStorageAccountType: 'Premium_LRS'
    adminUsername: 'azureuser'
    adminPassword: 'MyPassword#1'
    vmImagePublisher: 'MicrosoftWindowsDesktop'
    vmImageOffer: 'Windows-10'
    vmImageSku: 'win10-21h2-pro'
    osAHBLicenseType: 'Windows_Client'
    autoShutDown: true
  }
}

