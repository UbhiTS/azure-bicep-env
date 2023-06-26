// deployment time ~5 mins

// -------------------------

var deploySecondary = true
var deployTertiary = true

// =========================



var baseConfigPrimary = loadJsonContent('../../base/config/base-primary.json')
var baseConfigSecondary = loadJsonContent('../../base/config/base-secondary.json')
var baseConfigTertiary = loadJsonContent('../../base/config/base-tertiary.json')

var configPrimary = loadJsonContent('./config/primary.json')
var configSecondary = loadJsonContent('./config/secondary.json')
var configTertiary = loadJsonContent('./config/tertiary.json')

// resource groups

module primaryBastion './modules/bastion.bicep' = {
  name: 'deploy-primary-bastion'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  params: {
    baseConfig: baseConfigPrimary
    config: configPrimary
  }
}

module secondaryBastion './modules/bastion.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-bastion'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  params: {
    baseConfig: baseConfigSecondary
    config: configSecondary
  }
}

module tertiaryBastion './modules/bastion.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-bastion'
  scope: resourceGroup(baseConfigTertiary.rg.name)
  params: {
    baseConfig: baseConfigTertiary
    config: configTertiary
  }
}
