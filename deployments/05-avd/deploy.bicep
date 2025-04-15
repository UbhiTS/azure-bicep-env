// deployment time ~11 mins

// always rebuild this file after you deploy (or redeploy) users in the aadds module so that the latest ids of the groups and users are picked up from the domain.json file
// in case of AAD or service principal errors, see the aadds deploy.bicep file
// deploy this file again to refresh the icons on the remote desktop client once the host (pool) VMs are up and running

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

// https://github.com/pauldotyu/azure-virtual-desktop-bicep/tree/main/modules

var baseConfigEastUS = loadJsonContent('../../base/config/base-eus.json')
var baseConfigWestUS = loadJsonContent('../../base/config/base-wus.json')
var baseConfigSouthCentralUS = loadJsonContent('../../base/config/base-scus.json')


var configEastUS = loadJsonContent('./config/eus.json')
var configWestUS = loadJsonContent('./config/wus.json')
var configSouthCentralUS = loadJsonContent('./config/scus.json')

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
    domainConfig: domainConfig
    config: avdConfig
  }
}

module primaryAVD './modules/avd-control-plane.bicep' = {
  name: 'deploy-avd-control-plane-${configEastUS.deploymentName}'
  dependsOn: [ profilesStorage ]
  scope: resourceGroup(baseConfigEastUS.rg.name)
  params: {
    baseConfig: baseConfigEastUS
    domainConfig: domainConfig
    config: configEastUS
  }
}

module secondaryAVD './modules/avd-control-plane.bicep' = {
  name: 'deploy-avd-control-plane-${configWestUS.deploymentName}'
  dependsOn: [ profilesStorage ]
  scope: resourceGroup(baseConfigWestUS.rg.name)
  params: {
    baseConfig: baseConfigWestUS
    domainConfig: domainConfig
    config: configWestUS
  }
}

module tertiaryAVD './modules/avd-control-plane.bicep' = {
  name: 'deploy-avd-control-plane-${configSouthCentralUS.deploymentName}'
  dependsOn: [ profilesStorage ]
  scope: resourceGroup(baseConfigSouthCentralUS.rg.name)
  params: {
    baseConfig: baseConfigSouthCentralUS
    domainConfig: domainConfig
    config: configSouthCentralUS
  }
}

// module saNTFSPermissions './modules/avd-storage-account-ntfs-permissions.bicep' = {
//   name: 'sa-ntfs-permissions'
//   dependsOn: [ primaryAVD ]
//   scope: resourceGroup(baseConfigEastUS.rg.name)
//   params: {
//     sessionHostName: primaryAVD.outputs.sessionHostVM1Name
//   }
// }

module vmLoginRolesEastUS './modules/avd-vm-login-roles-assignment.bicep' = {
  name: 'deploy-vm-login-roles-assignment-eus'
  dependsOn: [ rg ]
  params: {
    baseConfig: baseConfigEastUS
    domainConfig: domainConfig
  }
}

module vmLoginRolesWestUS './modules/avd-vm-login-roles-assignment.bicep' = {
  name: 'deploy-vm-login-roles-assignment-wus'
  dependsOn: [ rg ]
  params: {
    baseConfig: baseConfigWestUS
    domainConfig: domainConfig
  }
}

module vmLoginRolesSouthCentralUS './modules/avd-vm-login-roles-assignment.bicep' = {
  name: 'deploy-vm-login-roles-assignment-scus'
  dependsOn: [ rg ]
  params: {
    baseConfig: baseConfigSouthCentralUS
    domainConfig: domainConfig
  }
}


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
