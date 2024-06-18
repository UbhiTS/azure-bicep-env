// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../../../base/config/base-primary.json')
// var config = loadJsonContent('../config/primary.json')
// var domainConfig = loadJsonContent('../../../base/config/domain.json')
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param config object
param domainConfig object
// ========================================================================

param currentUTCTime string = utcNow('u')
var expirationTime = dateTimeAdd(currentUTCTime, 'PT48H')

var location = baseConfig.rg.location

// create WVD hostpool

resource hp 'Microsoft.DesktopVirtualization/hostPools@2021-02-01-preview' = {
  name: config.avd.hostPool.name
  location: location
  properties: {
    friendlyName: config.avd.hostPool.friendlyName
    hostPoolType : config.avd.hostPool.type
    loadBalancerType : config.avd.hostPool.loadBalancerType
    preferredAppGroupType: 'Desktop'
    validationEnvironment: true
    customRdpProperty: 'drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:0;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;audiocapturemode:i:1;encode redirected video capture:i:1;redirected video capture encoding quality:i:2;camerastoredirect:s:*;screen mode id:i:1;smart sizing:i:1;dynamic resolution:i:1;autoreconnection enabled:i:1;redirectlocation:i:1;redirectwebauthn:i:1;desktopheight:i:900;desktopwidth:i:1600;desktopscalefactor:i:100'
    registrationInfo: {
      expirationTime: expirationTime
      token: null
      registrationTokenOperation: 'Update'
    }
  }
}

// deploy session hosts

module sessionHosts '../../../modules/vm.bicep' = [ for i in range(0, config.avd.sessionHosts.count): {
  name: 'deploy-${config.avd.hostPool.name}-${config.avd.sessionHosts.namePrefix}-${i}'
  params: {
    vNetName: baseConfig.hub.name
    sNetName: baseConfig.hub.subnets.dmzSubnet.name
    location: location
    vmName: '${config.avd.sessionHosts.namePrefix}-${i}'
    vmSize: config.avd.sessionHosts.vmSize
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    vmImageOffer: config.avd.sessionHosts.vmImageOffer
    vmImageSku: config.avd.sessionHosts.vmImageSku
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    hostPoolName: config.avd.hostPool.name
    hostPoolRegToken: reference(hp.id).registrationInfo.token // workaround for bicep hostpool token issue https://github.com/Azure/bicep-types-az/issues/2023
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}]

// create app groups

module appGroups './avd-app-group.bicep' = [for appGroup in config.avd.appGroups: {
  name: 'deploy-${appGroup.name}'
  dependsOn: [ sessionHosts ]
  params: {
    appGroupConfig: appGroup
    hostPoolId: hp.id
    location: location
  }
}]

// create workspace

var appGroupIds = [for appGroup in config.avd.appGroups: resourceId('Microsoft.DesktopVirtualization/applicationGroups', appGroup.name)]

resource ws 'Microsoft.DesktopVirtualization/workspaces@2022-04-01-preview' = {
  name: config.avd.workspace.name
  dependsOn: [ appGroups ]
  location: location
  properties: {
      friendlyName: config.avd.workspace.friendlyName
      applicationGroupReferences: appGroupIds
  }
}


module appGroupRoleAssignments './avd-app-group-role-assigments.bicep' = [for appGroup in config.avd.appGroups: {
  name: 'deploy-${appGroup.name}-role-assignments'
  dependsOn: [ appGroups ]
  params: {
    appGroupName: appGroup.Name
    assignToGroups: appGroup.assignToGroups
    domainConfig: domainConfig
  }
}]

output sessionHostVM1Id string = sessionHosts[0].outputs.id
output sessionHostVM1Name string = sessionHosts[0].outputs.name
