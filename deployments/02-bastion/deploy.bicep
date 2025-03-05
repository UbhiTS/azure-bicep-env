// deployment time ~5 mins

// -------------------------

var deployWestUS = true
var deploySouthCentralUS = true

// =========================



var baseConfigEastUS = loadJsonContent('../../base/config/base-eastus.json')
var baseConfigWestUS = loadJsonContent('../../base/config/base-westus.json')
var baseConfigSouthCentralUS = loadJsonContent('../../base/config/base-southcentralus.json')

var configEastUS = loadJsonContent('./config/eastus.json')
var configWestUS = loadJsonContent('./config/westus.json')
var configSouthCentralUS = loadJsonContent('./config/southcentralus.json')

// resource groups

module eastusBastion './modules/bastion.bicep' = {
  name: 'deploy-eastus-bastion'
  scope: resourceGroup(baseConfigEastUS.rg.name)
  params: {
    baseConfig: baseConfigEastUS
    config: configEastUS
  }
}

module westusBastion './modules/bastion.bicep' = if (deployWestUS) {
  name: 'deploy-westus-bastion'
  scope: resourceGroup(baseConfigWestUS.rg.name)
  params: {
    baseConfig: baseConfigWestUS
    config: configWestUS
  }
}

module southcentralusBastion './modules/bastion.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-bastion'
  scope: resourceGroup(baseConfigSouthCentralUS.rg.name)
  params: {
    baseConfig: baseConfigSouthCentralUS
    config: configSouthCentralUS
  }
}
