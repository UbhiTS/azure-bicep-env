// deployment time ~5 mins

// -------------------------

var deployWestUS = true
var deploySouthCentralUS = true

// =========================



var baseConfigEastUS = loadJsonContent('../../base/config/base-eus.json')
var baseConfigWestUS = loadJsonContent('../../base/config/base-wus.json')
var baseConfigSouthCentralUS = loadJsonContent('../../base/config/base-scus.json')

var configEastUS = loadJsonContent('./config/eus.json')
var configWestUS = loadJsonContent('./config/wus.json')
var configSouthCentralUS = loadJsonContent('./config/scus.json')

// resource groups

module eastusBastionRG '../../modules/rg.bicep' = {
  name: 'deploy-eastus-bastion-rg'
  scope: subscription()
  params: {
    config: configEastUS
  }
}

module westusBastionRG '../../modules/rg.bicep' = if (deployWestUS) {
  name: 'deploy-westus-bastion-rg'
  scope: subscription()
  params: {
    config: configWestUS
  }
}

module southcentralusBastionRG '../../modules/rg.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-bastion-rg'
  scope: subscription()
  params: {
    config: configSouthCentralUS
  }
}

module eastusBastion './modules/bastion.bicep' = {
  name: 'deploy-eastus-bastion'
  scope: resourceGroup(configEastUS.rg.name)
  dependsOn: [ eastusBastionRG ]
  params: {
    baseConfig: baseConfigEastUS
    config: configEastUS
  }
}

module westusBastion './modules/bastion.bicep' = if (deployWestUS) {
  name: 'deploy-westus-bastion'
  scope: resourceGroup(configWestUS.rg.name)
  dependsOn: [ westusBastionRG ]
  params: {
    baseConfig: baseConfigWestUS
    config: configWestUS
  }
}

module southcentralusBastion './modules/bastion.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-bastion'
  scope: resourceGroup(configSouthCentralUS.rg.name)
  dependsOn: [ southcentralusBastionRG ]
  params: {
    baseConfig: baseConfigSouthCentralUS
    config: configSouthCentralUS
  }
}
