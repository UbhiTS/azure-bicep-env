var params = loadJsonContent('../params.json')

module primaryNetworkVMs './infrastructure/primaryNetworkVMs.bicep' = {
  name: 'primaryNetworkVMsDeployment'
  scope: resourceGroup(params.primaryRGName)
  params: {
    deployPrimaryHubDMZVM: true
    deployPrimarySpoke1WorkloadVM: true
    deployPrimarySpoke2WorkloadVM: true
  }
}

module secondaryNetworkVMs './infrastructure/secondaryNetworkVMs.bicep' = {
  name: 'secondaryNetworkVMsDeployment'
  scope: resourceGroup(params.secondaryRGName)
  params: {
    deploySecondaryHubDMZVM: true
    deploySecondarySpoke1WorkloadVM: true
    deploySecondarySpoke2WorkloadVM: true
  }
}
