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

resource hp 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: config.avd.hostPool.name
  location: location
  properties: {
    friendlyName: config.avd.hostPool.friendlyName
    hostPoolType : config.avd.hostPool.type
    loadBalancerType : config.avd.hostPool.loadBalancerType
    preferredAppGroupType: 'Desktop'
    validationEnvironment: true
    customRdpProperty: 'drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1'
    registrationInfo: {
      expirationTime: expirationTime
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
    hostPoolRegToken: hp.properties.registrationInfo.token
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}]

// create app groups

module appGroups './avd-app-group.bicep' = [for appGroup in config.avd.appGroups: {
  name: 'deploy-${appGroup.name}'
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
