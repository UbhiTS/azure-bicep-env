// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../../../base/config/base-tertiary.json')
// var config = loadJsonContent('../config/primary.json')
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param config object
// ========================================================================



var location = baseConfig.rg.location

resource hub 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: baseConfig.hub.name
  scope: resourceGroup(baseConfig.rg.name)
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: baseConfig.hub.subnets.azureBastionSubnet.name
  parent: hub
}

resource bastionPip 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: config.pip.name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: config.host.name
  location: location
  properties: {
    ipConfigurations: [
      { 
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
}

output id string = bastionHost.id
output name string = bastionHost.name
