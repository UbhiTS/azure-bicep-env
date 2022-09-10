// deployment time ~3 mins

// az bicep decompile -f .\pathtoexportarmfile to create the biCep file 

var configPrimary = loadJsonContent('./config/base-primary.json')
var configSecondary = loadJsonContent('./config/base-secondary.json')
var configTertiary = loadJsonContent('./config/base-tertiary.json')

var deploySecondary = true
var deployTertiary = true

// resource groups

module primaryRG '../modules/rg.bicep' = {
  name: 'deploy-primary-rg'
  scope: subscription()
  params: {
    config: configPrimary
  }
}

module secondaryRG '../modules/rg.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-rg'
  scope: subscription()
  params: {
    config: configSecondary
  }
}

module tertiaryRG '../modules/rg.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-rg'
  scope: subscription()
  params: {
    config: configTertiary
  }
}

// nsg

module primaryNSG '../modules/nsg-default.bicep' = {
  name: 'deploy-primary-nsg'
  dependsOn: [ primaryRG ]
  scope: resourceGroup(configPrimary.rg.name)
  params: {
    config: configPrimary
  }
}

module secondaryNSG '../modules/nsg-default.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-nsg'
  dependsOn: [ secondaryRG ]
  scope: resourceGroup(configSecondary.rg.name)
  params: {
    config: configSecondary
  }
}

module tertiaryNSG '../modules/nsg-default.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-nsg'
  dependsOn: [ tertiaryRG ]
  scope: resourceGroup(configTertiary.rg.name)
  params: {
    config: configTertiary
  }
}

// hubs

module primaryHubVNet '../modules/hub.bicep' = {
  name: 'deploy-primary-hub'
  dependsOn: [ primaryNSG ]
  scope: resourceGroup(configPrimary.rg.name)
  params: {
    config: configPrimary
    dmzNsgId: primaryNSG.outputs.id
  }
}

module secondaryHubVNet '../modules/hub.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-hub'
  dependsOn: [ secondaryNSG ]
  scope: resourceGroup(configSecondary.rg.name)
  params: {
    config: configSecondary
    dmzNsgId: secondaryNSG.outputs.id
  }
}

module tertiaryHubVNet '../modules/hub.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-hub'
  dependsOn: [ tertiaryNSG ]
  scope: resourceGroup(configTertiary.rg.name)
  params: {
    config: configTertiary
    dmzNsgId: tertiaryNSG.outputs.id
  }
}

// peerings

module primaryHubToSecondaryHubPeering '../modules/peering.bicep' = if (deploySecondary) {
  name: 'deploy-primary-secondary-hub-peering'
  scope: resourceGroup(configPrimary.rg.name)
  dependsOn: [ primaryHubVNet, secondaryHubVNet ]
  params: {
    localVNetName: primaryHubVNet.outputs.name
    remoteVNetId: secondaryHubVNet.outputs.id
    remoteVNetName: secondaryHubVNet.outputs.name
  }
}

module secondaryHubToPrimaryHubPeering '../modules/peering.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-primary-hub-peering'
  scope: resourceGroup(configSecondary.rg.name)
  dependsOn: [ primaryHubVNet, secondaryHubVNet ]
  params: {
    localVNetName: secondaryHubVNet.outputs.name
    remoteVNetId: primaryHubVNet.outputs.id
    remoteVNetName: primaryHubVNet.outputs.name
  }
}

module primaryHubToTertiaryHubPeering '../modules/peering.bicep' = if (deployTertiary) {
  name: 'deploy-primary-tertiary-hub-peering'
  scope: resourceGroup(configPrimary.rg.name)
  dependsOn: [ primaryHubVNet, tertiaryHubVNet ]
  params: {
    localVNetName: primaryHubVNet.outputs.name
    remoteVNetId: tertiaryHubVNet.outputs.id
    remoteVNetName: tertiaryHubVNet.outputs.name
  }
}

module tertiaryHubToPrimaryHubPeering '../modules/peering.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-primary-hub-peering'
  scope: resourceGroup(configTertiary.rg.name)
  dependsOn: [ primaryHubVNet, tertiaryHubVNet ]
  params: {
    localVNetName: tertiaryHubVNet.outputs.name
    remoteVNetId: primaryHubVNet.outputs.id
    remoteVNetName: primaryHubVNet.outputs.name
  }
}

module secondaryHubToTertiaryHubPeering '../modules/peering.bicep' = if (deploySecondary && deployTertiary) {
  name: 'deploy-secondary-tertiary-hub-peering'
  scope: resourceGroup(configSecondary.rg.name)
  dependsOn: [ secondaryHubVNet, tertiaryHubVNet ]
  params: {
    localVNetName: secondaryHubVNet.outputs.name
    remoteVNetId: tertiaryHubVNet.outputs.id
    remoteVNetName: tertiaryHubVNet.outputs.name
  }
}

module tertiaryHubToSecondaryHubPeering '../modules/peering.bicep' = if (deploySecondary && deployTertiary) {
  name: 'deploy-tertiary-secondary-hub-peering'
  scope: resourceGroup(configTertiary.rg.name)
  dependsOn: [ secondaryHubVNet, tertiaryHubVNet ]
  params: {
    localVNetName: tertiaryHubVNet.outputs.name
    remoteVNetId: secondaryHubVNet.outputs.id
    remoteVNetName: secondaryHubVNet.outputs.name
  }
}
