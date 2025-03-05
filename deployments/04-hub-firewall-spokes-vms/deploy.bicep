// deployment time: 35 mins


// -------------------------

var deployWestUS = true
var deploySouthCentralUS = true

var deploySpokeVMs = true

// =========================

var baseConfigEastUS = loadJsonContent('../../base/config/base-eastus.json')
var baseConfigWestUS = loadJsonContent('../../base/config/base-westus.json')
var baseConfigSouthCentralUS = loadJsonContent('../../base/config/base-southcentralus.json')

var domainConfig = loadJsonContent('../../base/config/domain.json')

var configEastUS = loadJsonContent('./config/eastus.json')
var configWestUS = loadJsonContent('./config/westus.json')
var configSouthCentralUS = loadJsonContent('./config/southcentralus.json')

// resource groups

module eastusSecuredRG '../../modules/rg.bicep' = {
  name: 'deploy-eastus-spokes-rg'
  scope: subscription()
  params: {
    config: configEastUS
  }
}

module westusSecuredRG '../../modules/rg.bicep' = if (deployWestUS) {
  name: 'deploy-westus-spokes-rg'
  scope: subscription()
  params: {
    config: configWestUS
  }
}

module southcentralusSecuredRG '../../modules/rg.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-spokes-rg'
  scope: subscription()
  params: {
    config: configSouthCentralUS
  }
}

// network - hub firewalls, secured spokes

module eastusSecuredNetworkDeployment './modules/blueprint.bicep' = {
  name: 'deploy-eastus-spokes-network'
  scope: resourceGroup(configEastUS.rg.name)
  dependsOn: [ eastusSecuredRG ]
  params:{
    baseConfig: baseConfigEastUS
    domainConfig: domainConfig
    config: configEastUS
    extHub1Config: configWestUS
    extHub2Config: configSouthCentralUS
    deploySpokeWorkloadVMs: deploySpokeVMs
  }
}

module westusSecuredNetworkDeployment './modules/blueprint.bicep' = if (deployWestUS) {
  name: 'deploy-westus-spokes-network'
  scope: resourceGroup(configWestUS.rg.name)
  dependsOn: [ westusSecuredRG ]
  params:{
    baseConfig: baseConfigWestUS
    domainConfig: domainConfig
    config: configWestUS
    extHub1Config: configEastUS
    extHub2Config: configSouthCentralUS
    deploySpokeWorkloadVMs: deploySpokeVMs
  }
}

module southcentralusSecuredNetworkDeployment './modules/blueprint.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-spokes-network'
  scope: resourceGroup(configSouthCentralUS.rg.name)
  dependsOn: [ southcentralusSecuredRG ]
  params:{
    baseConfig: baseConfigSouthCentralUS
    domainConfig: domainConfig
    config: configSouthCentralUS
    extHub1Config: configEastUS
    extHub2Config: configWestUS
    deploySpokeWorkloadVMs: deploySpokeVMs
  }
}

// inter hub route tables

module eastusInterHubRouteTableDeployment './modules/hub-rt.bicep' = {
  name: 'deploy-eastus-fw-subnet-interhub-rt'
  scope: resourceGroup(baseConfigEastUS.rg.name)
  dependsOn: [ eastusSecuredNetworkDeployment ]
  params:{
    baseConfig: baseConfigEastUS
    config: configEastUS
    extHub1Config: configWestUS
    extHub1FWPvtIpAddress: westusSecuredNetworkDeployment.outputs.hubFWPvtIPAddress
    extHub2Config: configSouthCentralUS
    extHub2FWPvtIpAddress: southcentralusSecuredNetworkDeployment.outputs.hubFWPvtIPAddress
  }
}

module eastusHubRTAttachment './modules/hub-rt-attachment.bicep' = {
  name: 'deploy-eastus-fw-subnet-interhub-rt-attachment'
  scope: resourceGroup(baseConfigEastUS.rg.name)
  dependsOn: [ eastusInterHubRouteTableDeployment ]
  params:{
    baseConfig: baseConfigEastUS
    interHubRouteTableId: eastusInterHubRouteTableDeployment.outputs.id
  }
}

module westusInterHubRouteTableDeployment './modules/hub-rt.bicep' = if (deployWestUS) {
  name: 'deploy-westus-fw-subnet-interhub-rt'
  scope: resourceGroup(baseConfigWestUS.rg.name)
  dependsOn: [ westusSecuredNetworkDeployment ]
  params:{
    baseConfig: baseConfigWestUS
    config: configWestUS
    extHub1Config: configEastUS
    extHub1FWPvtIpAddress: eastusSecuredNetworkDeployment.outputs.hubFWPvtIPAddress
    extHub2Config: configSouthCentralUS
    extHub2FWPvtIpAddress: southcentralusSecuredNetworkDeployment.outputs.hubFWPvtIPAddress
  }
}

module westusHubRTAttachment './modules/hub-rt-attachment.bicep' = if (deployWestUS) {
  name: 'deploy-westus-fw-subnet-interhub-rt-attachment'
  scope: resourceGroup(baseConfigWestUS.rg.name)
  dependsOn: [ westusInterHubRouteTableDeployment ]
  params:{
    baseConfig: baseConfigWestUS
    interHubRouteTableId: westusInterHubRouteTableDeployment.outputs.id
  }
}

module southcentralusInterHubRouteTableDeployment './modules/hub-rt.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-fw-subnet-interhub-rt'
  scope: resourceGroup(baseConfigSouthCentralUS.rg.name)
  dependsOn: [ southcentralusSecuredNetworkDeployment ]
  params:{
    baseConfig: baseConfigSouthCentralUS
    config: configSouthCentralUS
    extHub1Config: configEastUS
    extHub1FWPvtIpAddress: eastusSecuredNetworkDeployment.outputs.hubFWPvtIPAddress
    extHub2Config: configWestUS
    extHub2FWPvtIpAddress: westusSecuredNetworkDeployment.outputs.hubFWPvtIPAddress
  }
}


module southcentralusHubRTAttachment './modules/hub-rt-attachment.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-fw-subnet-interhub-rt-attachment'
  scope: resourceGroup(baseConfigSouthCentralUS.rg.name)
  dependsOn: [ southcentralusInterHubRouteTableDeployment ]
  params:{
    baseConfig: baseConfigSouthCentralUS
    interHubRouteTableId: southcentralusInterHubRouteTableDeployment.outputs.id
  }
}
