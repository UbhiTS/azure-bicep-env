// deployment time ~3 mins

// az bicep decompile -f .\pathtoexportarmfile to create the biCep file 

var configEastUS = loadJsonContent('./config/base-eastus.json')
var configWestUS = loadJsonContent('./config/base-westus.json')
var configSouthCentralUS = loadJsonContent('./config/base-southcentralus.json')

var deployWestUS = true
var deploySouthCentralUS = true

// resource groups

module eastusRG '../modules/rg.bicep' = {
  name: 'deploy-eastus-rg'
  scope: subscription()
  params: {
    config: configEastUS
  }
}

module westusRG '../modules/rg.bicep' = if (deployWestUS) {
  name: 'deploy-westus-rg'
  scope: subscription()
  params: {
    config: configWestUS
  }
}

module southcentralusRG '../modules/rg.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-rg'
  scope: subscription()
  params: {
    config: configSouthCentralUS
  }
}

// nsg

module eastusNSG '../modules/nsg-default.bicep' = {
  name: 'deploy-eastus-nsg'
  dependsOn: [ eastusRG ]
  scope: resourceGroup(configEastUS.rg.name)
  params: {
    config: configEastUS
  }
}

module westusNSG '../modules/nsg-default.bicep' = if (deployWestUS) {
  name: 'deploy-westus-nsg'
  dependsOn: [ westusRG ]
  scope: resourceGroup(configWestUS.rg.name)
  params: {
    config: configWestUS
  }
}

module southcentralusNSG '../modules/nsg-default.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-nsg'
  dependsOn: [ southcentralusRG ]
  scope: resourceGroup(configSouthCentralUS.rg.name)
  params: {
    config: configSouthCentralUS
  }
}

// hubs

module eastusHubVNet '../modules/hub.bicep' = {
  name: 'deploy-eastus-hub'
  dependsOn: [ eastusNSG ]
  scope: resourceGroup(configEastUS.rg.name)
  params: {
    config: configEastUS
    dmzNsgId: eastusNSG.outputs.id
  }
}

module westusHubVNet '../modules/hub.bicep' = if (deployWestUS) {
  name: 'deploy-westus-hub'
  dependsOn: [ westusNSG ]
  scope: resourceGroup(configWestUS.rg.name)
  params: {
    config: configWestUS
    dmzNsgId: westusNSG.outputs.id
  }
}

module southcentralusHubVNet '../modules/hub.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-hub'
  dependsOn: [ southcentralusNSG ]
  scope: resourceGroup(configSouthCentralUS.rg.name)
  params: {
    config: configSouthCentralUS
    dmzNsgId: southcentralusNSG.outputs.id
  }
}

// peerings

module eastusHubToWestUSHubPeering '../modules/peering.bicep' = if (deployWestUS) {
  name: 'deploy-eastus-westus-hub-peering'
  scope: resourceGroup(configEastUS.rg.name)
  dependsOn: [ eastusHubVNet, westusHubVNet ]
  params: {
    localVNetName: eastusHubVNet.outputs.name
    remoteVNetId: westusHubVNet.outputs.id
    remoteVNetName: westusHubVNet.outputs.name
  }
}

module westusHubToEastUSHubPeering '../modules/peering.bicep' = if (deployWestUS) {
  name: 'deploy-westus-eastus-hub-peering'
  scope: resourceGroup(configWestUS.rg.name)
  dependsOn: [ eastusHubVNet, westusHubVNet ]
  params: {
    localVNetName: westusHubVNet.outputs.name
    remoteVNetId: eastusHubVNet.outputs.id
    remoteVNetName: eastusHubVNet.outputs.name
  }
}

module eastusHubToSouthCentralUSHubPeering '../modules/peering.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-eastus-southcentralus-hub-peering'
  scope: resourceGroup(configEastUS.rg.name)
  dependsOn: [ eastusHubVNet, southcentralusHubVNet ]
  params: {
    localVNetName: eastusHubVNet.outputs.name
    remoteVNetId: southcentralusHubVNet.outputs.id
    remoteVNetName: southcentralusHubVNet.outputs.name
  }
}

module southcentralusHubToEastUSHubPeering '../modules/peering.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-eastus-hub-peering'
  scope: resourceGroup(configSouthCentralUS.rg.name)
  dependsOn: [ eastusHubVNet, southcentralusHubVNet ]
  params: {
    localVNetName: southcentralusHubVNet.outputs.name
    remoteVNetId: eastusHubVNet.outputs.id
    remoteVNetName: eastusHubVNet.outputs.name
  }
}

module westusHubToSouthCentralUSHubPeering '../modules/peering.bicep' = if (deployWestUS && deploySouthCentralUS) {
  name: 'deploy-westus-southcentralus-hub-peering'
  scope: resourceGroup(configWestUS.rg.name)
  dependsOn: [ westusHubVNet, southcentralusHubVNet ]
  params: {
    localVNetName: westusHubVNet.outputs.name
    remoteVNetId: southcentralusHubVNet.outputs.id
    remoteVNetName: southcentralusHubVNet.outputs.name
  }
}

module southcentralusHubToWestUSHubPeering '../modules/peering.bicep' = if (deployWestUS && deploySouthCentralUS) {
  name: 'deploy-southcentralus-westus-hub-peering'
  scope: resourceGroup(configSouthCentralUS.rg.name)
  dependsOn: [ westusHubVNet, southcentralusHubVNet ]
  params: {
    localVNetName: southcentralusHubVNet.outputs.name
    remoteVNetId: westusHubVNet.outputs.id
    remoteVNetName: westusHubVNet.outputs.name
  }
}
