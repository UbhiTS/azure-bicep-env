var params = loadJsonContent('../../params.json')

var secondaryRG = resourceGroup(params.secondaryRGName)

param deploySecondaryHubDMZVM bool = false
param deploySecondarySpoke1WorkloadVM bool = false
param deploySecondarySpoke2WorkloadVM bool = false

module secondaryHubDMZVM './components/vm.bicep' = if (deploySecondaryHubDMZVM) {
  name: 'secondaryHubDMZVMDeployment'
  scope: secondaryRG
  params: {
    vNetName: params.secondaryNetwork.hub.name
    sNetName: params.secondaryNetwork.hub.dmzSubnetName
    location: params.secondaryRGLocation
    vmName: 'sec-hub-vm1'
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

module secondarySpoke1WorkloadVM './components/vm.bicep' = if (deploySecondarySpoke1WorkloadVM) {
  name: 'secondarySpoke1WorkloadVMDeployment'
  scope: secondaryRG
  params: {
    vNetName: params.secondaryNetwork.spoke1.name
    sNetName: params.secondaryNetwork.spoke1.workloadSubnetName
    location: params.secondaryRGLocation
    vmName: 'sec-spoke1-vm1'
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

module secondarySpoke2WorkloadVM './components/vm.bicep' = if (deploySecondarySpoke2WorkloadVM) {
  name: 'secondarySpoke2WorkloadVMDeployment'
  scope: secondaryRG
  params: {
    vNetName: params.secondaryNetwork.spoke2.name
    sNetName: params.secondaryNetwork.spoke2.workloadSubnetName
    location: params.secondaryRGLocation
    vmName: 'sec-spoke2-vm1'
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
