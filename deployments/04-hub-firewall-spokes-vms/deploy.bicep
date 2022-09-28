

// -------------------------

var deploySecondary = true
var deployTertiary = true

var deploySpokeVMs = true

// =========================

var baseConfigPrimary = loadJsonContent('../../base/config/base-primary.json')
var baseConfigSecondary = loadJsonContent('../../base/config/base-secondary.json')
var baseConfigTertiary = loadJsonContent('../../base/config/base-tertiary.json')

var domainConfig = loadJsonContent('../../base/config/domain.json')

var configPrimary = loadJsonContent('./config/primary.json')
var configSecondary = loadJsonContent('./config/secondary.json')
var configTertiary = loadJsonContent('./config/tertiary.json')

// resource groups

module primarySecuredRG '../../modules/rg.bicep' = {
  name: 'deploy-primary-secured-rg'
  scope: subscription()
  params: {
    config: configPrimary
  }
}

module secondarySecuredRG '../../modules/rg.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-secured-rg'
  scope: subscription()
  params: {
    config: configSecondary
  }
}

module tertiarySecuredRG '../../modules/rg.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-secured-rg'
  scope: subscription()
  params: {
    config: configTertiary
  }
}

// network - hub firewalls, secured spokes

module primarySecuredNetworkDeployment './modules/blueprint.bicep' = {
  name: 'deploy-primary-secured-network'
  scope: resourceGroup(configPrimary.rg.name)
  dependsOn: [ primarySecuredRG ]
  params:{
    baseConfig: baseConfigPrimary
    domainConfig: domainConfig
    config: configPrimary
    extHub1Config: configSecondary
    extHub2Config: configTertiary
    deploySpokeWorkloadVMs: deploySpokeVMs
  }
}

module secondarySecuredNetworkDeployment './modules/blueprint.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-secured-network'
  scope: resourceGroup(configSecondary.rg.name)
  dependsOn: [ secondarySecuredRG ]
  params:{
    baseConfig: baseConfigSecondary
    domainConfig: domainConfig
    config: configSecondary
    extHub1Config: configPrimary
    extHub2Config: configTertiary
    deploySpokeWorkloadVMs: deploySpokeVMs
  }
}

module tertiarySecuredNetworkDeployment './modules/blueprint.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-secured-network'
  scope: resourceGroup(configTertiary.rg.name)
  dependsOn: [ tertiarySecuredRG ]
  params:{
    baseConfig: baseConfigTertiary
    domainConfig: domainConfig
    config: configTertiary
    extHub1Config: configPrimary
    extHub2Config: configSecondary
    deploySpokeWorkloadVMs: deploySpokeVMs
  }
}

// inter hub route tables

module primaryInterHubRouteTableDeployment './modules/hub-rt.bicep' = {
  name: 'deploy-primary-fw-subnet-interhub-rt'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  dependsOn: [ primarySecuredNetworkDeployment ]
  params:{
    baseConfig: baseConfigPrimary
    config: configPrimary
    extHub1Config: configSecondary
    extHub1FWPvtIpAddress: secondarySecuredNetworkDeployment.outputs.hubFWPvtIPAddress
    extHub2Config: configTertiary
    extHub2FWPvtIpAddress: tertiarySecuredNetworkDeployment.outputs.hubFWPvtIPAddress
  }
}

module primaryHubRTAttachment './modules/hub-rt-attachment.bicep' = {
  name: 'deploy-primary-fw-subnet-interhub-rt-attachment'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  dependsOn: [ primaryInterHubRouteTableDeployment ]
  params:{
    baseConfig: baseConfigPrimary
    interHubRouteTableId: primaryInterHubRouteTableDeployment.outputs.id
  }
}

module secondaryInterHubRouteTableDeployment './modules/hub-rt.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-fw-subnet-interhub-rt'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  dependsOn: [ secondarySecuredNetworkDeployment ]
  params:{
    baseConfig: baseConfigSecondary
    config: configSecondary
    extHub1Config: configPrimary
    extHub1FWPvtIpAddress: primarySecuredNetworkDeployment.outputs.hubFWPvtIPAddress
    extHub2Config: configTertiary
    extHub2FWPvtIpAddress: tertiarySecuredNetworkDeployment.outputs.hubFWPvtIPAddress
  }
}

module secondaryHubRTAttachment './modules/hub-rt-attachment.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-fw-subnet-interhub-rt-attachment'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  dependsOn: [ secondaryInterHubRouteTableDeployment ]
  params:{
    baseConfig: baseConfigSecondary
    interHubRouteTableId: secondaryInterHubRouteTableDeployment.outputs.id
  }
}

module tertiaryInterHubRouteTableDeployment './modules/hub-rt.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-fw-subnet-interhub-rt'
  scope: resourceGroup(baseConfigTertiary.rg.name)
  dependsOn: [ tertiarySecuredNetworkDeployment ]
  params:{
    baseConfig: baseConfigTertiary
    config: configTertiary
    extHub1Config: configPrimary
    extHub1FWPvtIpAddress: primarySecuredNetworkDeployment.outputs.hubFWPvtIPAddress
    extHub2Config: configSecondary
    extHub2FWPvtIpAddress: secondarySecuredNetworkDeployment.outputs.hubFWPvtIPAddress
  }
}


module tertiaryHubRTAttachment './modules/hub-rt-attachment.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-fw-subnet-interhub-rt-attachment'
  scope: resourceGroup(baseConfigTertiary.rg.name)
  dependsOn: [ tertiaryInterHubRouteTableDeployment ]
  params:{
    baseConfig: baseConfigTertiary
    interHubRouteTableId: tertiaryInterHubRouteTableDeployment.outputs.id
  }
}
