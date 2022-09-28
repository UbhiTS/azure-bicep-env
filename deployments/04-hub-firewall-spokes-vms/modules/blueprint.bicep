// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../../../base/config/base-primary.json')
// var domainConfig = loadJsonContent('../../../base/config/domain.json')
// var config = loadJsonContent('../config/primary.json')
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param domainConfig object
param config object
// ========================================================================

param deploySpokeWorkloadVMs bool
param extHub1Config object
param extHub2Config object

var location = baseConfig.rg.location

// existing hub and nsg resources references

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: baseConfig.nsg.name
  scope: resourceGroup(baseConfig.rg.name)
}

resource hub 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: baseConfig.hub.name
  scope: resourceGroup(baseConfig.rg.name)
}

// firewall

module hubFW './firewall.bicep' = {
  name: 'deploy-hub-fw'
  // https://docs.microsoft.com/en-us/azure/firewall/firewall-faq#are-there-any-firewall-resource-group-restrictions
  // Are there any firewall resource group restrictions?
  // Yes. The firewall, VNet, and the public IP address all must be in the same resource group.
  scope: resourceGroup(baseConfig.rg.name) 
  params: {
    baseConfig: baseConfig
    config: config
    extHub1Name: extHub1Config.deploymentName
    extHub1SecuredSpokeAddresses: [ extHub1Config.spokes.spoke1.addressPrefix, extHub1Config.spokes.spoke2.addressPrefix ]
    extHub2Name: extHub2Config.deploymentName
    extHub2SecuredSpokeAddresses: [ extHub2Config.spokes.spoke1.addressPrefix, extHub2Config.spokes.spoke2.addressPrefix ]
  }
}

// routes

module securedSpokesRT './spokes-rt.bicep' = {
  name: '${config.deploymentName}-secured-spokes-to-fw-rt'
  dependsOn: [ hubFW ]
  params: {
    hubFWPvtIPAddress: hubFW.outputs.azFWPvtIPAddress
    config: config
  }
}

// spokes

module spokeVnet1 '../../../modules/spoke.bicep' = {
  name: 'deploy-${config.deploymentName}-secured-spoke1-vnet'
  dependsOn: [ securedSpokesRT ]
  params: {
    baseConfig: baseConfig
    config: config.spokes.spoke1
    nsgId: nsg.id
    routeTableId: securedSpokesRT.outputs.id
  }
}

module spokeVnet2 '../../../modules/spoke.bicep' = {
  name: 'deploy-${config.deploymentName}-secured-spoke2-vnet'
  dependsOn: [ securedSpokesRT ]
  params: {
    baseConfig: baseConfig
    config: config.spokes.spoke2
    nsgId: nsg.id
    routeTableId: securedSpokesRT.outputs.id
  }
}

// peerings

module spoke1ToHubPeering '../../../modules/peering.bicep' = {
  name: 'deploy-${config.deploymentName}-spoke1-to-hub-peering'
  dependsOn: [ spokeVnet1 ]
  params: {
    localVNetName: spokeVnet1.outputs.name
    remoteVNetId: hub.id
    remoteVNetName: hub.name
  }
}

module hubToSpoke1Peering '../../../modules/peering.bicep' = {
  name: 'deploy-${config.deploymentName}-hub-to-spoke1-peering'
  scope: resourceGroup(baseConfig.rg.name)
  dependsOn: [ spokeVnet1 ]
  params: {
    localVNetName: hub.name
    remoteVNetId: spokeVnet1.outputs.id
    remoteVNetName: spokeVnet1.outputs.name
  }
}

module spoke2ToHubPeering '../../../modules/peering.bicep' = {
  name: 'deploy-${config.deploymentName}-spoke2-to-hub-peering'
  dependsOn: [ spokeVnet2 ]
  params: {
    localVNetName: spokeVnet2.outputs.name
    remoteVNetId: hub.id
    remoteVNetName: hub.name
  }
}

module hubToSpoke2Peering '../../../modules/peering.bicep' = {
  name: 'deploy-${config.deploymentName}-hub-to-spoke2-peering'
  scope: resourceGroup(baseConfig.rg.name)
  dependsOn: [ spokeVnet2 ]
  params: {
    localVNetName: hub.name
    remoteVNetId: spokeVnet2.outputs.id
    remoteVNetName: spokeVnet2.outputs.name
  }
}

// vms

module spoke1WorkloadVM '../../../modules/vm.bicep' = if (deploySpokeWorkloadVMs) {
  name: 'deploy-${config.deploymentName}-spoke1-workload-vm'
  dependsOn: [ spokeVnet1 ]
  params: {
    vNetName: config.spokes.spoke1.name
    sNetName: config.spokes.spoke1.workloadSubnetName
    location: location
    vmName: 'spoke1-vm1' // maxlength = 15
    vmSize: 'Standard_D2s_v5'
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
    autoShutDown: true
  }
}

module spoke2WorkloadVM '../../../modules/vm.bicep' = if (deploySpokeWorkloadVMs) {
  name: 'deploy-${config.deploymentName}-spoke2-workload-vm'
  dependsOn: [ spokeVnet2 ]
  params: {
    vNetName: config.spokes.spoke2.name
    sNetName: config.spokes.spoke2.workloadSubnetName
    location: location
    vmName: 'spoke2-vm1' // maxlength = 15
    vmSize: 'Standard_D2s_v5'
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
    autoShutDown: true
  }
}

output hubFWPvtIPAddress string = hubFW.outputs.azFWPvtIPAddress
