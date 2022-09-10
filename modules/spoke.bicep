// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../base/config/primary.json')
// var primaryConfig = loadJsonContent('../deployments/hub-firewall-spokes-vms/config/primary.json')
// var config = primaryConfig.spokes.spoke1
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param config object
param nsgId string = ''
param routeTableId string = ''
// ========================================================================


resource spoke 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: config.name
  location: baseConfig.rg.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        config.addressPrefix
      ]
    }
    subnets: [
      {
        name: config.managementSubnetName
        properties: {
          addressPrefix: config.managementSubnetCIDR
          networkSecurityGroup: {
            id: nsgId == '' ? null : nsgId
          }
          routeTable: {
            id: routeTableId == '' ? null : routeTableId
          }
        }
      }
      {
        name: config.workloadSubnetName
        properties: {
          addressPrefix: config.workloadSubnetCIDR
          networkSecurityGroup: {
            id: nsgId == '' ? null : nsgId
          }
          routeTable: {
            id: routeTableId == '' ? null : routeTableId
          }
        }
      }
    ]
  }
}

output id string = spoke.id
output name string = spoke.name
