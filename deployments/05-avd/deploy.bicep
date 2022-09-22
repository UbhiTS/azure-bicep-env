// deployment time ~11 mins

// https://github.com/pauldotyu/azure-virtual-desktop-bicep/tree/main/modules

// https://learn.microsoft.com/en-us/azure/virtual-desktop/environment-setup#app-groups
// We don't support assigning both the RemoteApp and desktop app groups in a single host pool to the same user. 
// Doing so will cause a single user to have two user sessions in a single host pool. 
// Users aren't supposed to have two active user sessions at the same time, as this can cause the following things to happen:
// - The session hosts become overloaded
// - Users get stuck when trying to login
// - Connections won't work
// - The screen turns black
// - The application crashes
// - Other negative effects on end-user experience and session performance


var baseConfigPrimary = loadJsonContent('../../base/config/base-primary.json')
var baseConfigSecondary = loadJsonContent('../../base/config/base-secondary.json')
var baseConfigTertiary = loadJsonContent('../../base/config/base-tertiary.json')

var configPrimary = loadJsonContent('./config/primary.json')
var configSecondary = loadJsonContent('./config/secondary.json')
var configTertiary = loadJsonContent('./config/tertiary.json')

var avdConfig = loadJsonContent('../../base/config/avd.json')
var domainConfig = loadJsonContent('../../base/config/domain.json')

module rg '../../modules/rg.bicep' = {
  name: 'deploy-avd-rg'
  scope: subscription()
  params: {
    config: avdConfig
  }
}

module profilesStorage './modules/storage.bicep' = {
  name: 'deploy-avd-storage'
  dependsOn: [ rg ]
  scope: resourceGroup(avdConfig.rg.name)
  params: {
    config: avdConfig
  }
}

module primaryAVD './modules/avd-control-plane.bicep' = {
  name: 'deploy-avd-control-plane-${configPrimary.deploymentName}'
  dependsOn: [ profilesStorage ]
  scope: resourceGroup(baseConfigPrimary.rg.name)
  params: {
    baseConfig: baseConfigPrimary
    domainConfig: domainConfig
    config: configPrimary
  }
}

module secondaryAVD './modules/avd-control-plane.bicep' = {
  name: 'deploy-avd-control-plane-${configSecondary.deploymentName}'
  dependsOn: [ profilesStorage ]
  scope: resourceGroup(baseConfigSecondary.rg.name)
  params: {
    baseConfig: baseConfigSecondary
    domainConfig: domainConfig
    config: configSecondary
  }
}

module tertiaryAVD './modules/avd-control-plane.bicep' = {
  name: 'deploy-avd-control-plane-${configTertiary.deploymentName}'
  dependsOn: [ profilesStorage ]
  scope: resourceGroup(baseConfigTertiary.rg.name)
  params: {
    baseConfig: baseConfigTertiary
    domainConfig: domainConfig
    config: configTertiary
  }
}

module vmLoginRolesAssignmentPrimary './modules/vm-login-roles-assignment.bicep' = [ for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'assign-vm-login-role-${group.userPrefix}-on-${baseConfigPrimary.rg.name}'
  dependsOn: [ rg ]
  scope: resourceGroup(baseConfigPrimary.rg.name)
  params: {
    adGroupId: group.objectId
    isAdmin: group.type == 'avdAdmin'
  }
}]

module vmLoginRolesAssignmentSecondary './modules/vm-login-roles-assignment.bicep' = [ for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'assign-vm-login-role-${group.userPrefix}-on-${baseConfigSecondary.rg.name}'
  dependsOn: [ rg ]
  scope: resourceGroup(baseConfigSecondary.rg.name)
  params: {
    adGroupId: group.objectId
    isAdmin: group.type == 'avdAdmin'
  }
}]

module vmLoginRolesAssignmentTertiary './modules/vm-login-roles-assignment.bicep' = [ for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'assign-vm-login-role-${group.userPrefix}-on-${baseConfigTertiary.rg.name}'
  dependsOn: [ rg ]
  scope: resourceGroup(baseConfigTertiary.rg.name)
  params: {
    adGroupId: group.objectId
    isAdmin: group.type == 'avdAdmin'
  }
}]

//Create Diagnotic Setting for WVD components
// module avdMonitor './modules/monitor.bicep' = {
//   name : 'myBicepLADiag'
//   scope: resourceGroup(wvdBackplaneResourceGroup)
//   params: {
//     logAnalyticslocation : logAnalyticslocation
//     logAnalyticsWorkspaceID : wvdla.id
//     hostpoolName : hostpoolName
//     workspaceName : workspaceName
//     logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
//   }
// }
