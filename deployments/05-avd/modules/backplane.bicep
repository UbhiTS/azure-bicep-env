// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../../../base/config/base-primary.json')
// var domainConfig = loadJsonContent('../../../base/config/domain.json')
// var config = loadJsonContent('../config/primary.json')
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param domainConfig object
param config object
// ========================================================================

param currentUTCTime string = utcNow('u')
var expirationTime = dateTimeAdd(currentUTCTime, 'PT48H')

var location = baseConfig.rg.location

// create WVD hostpool

resource hp 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: config.avd.hostPoolName
  location: location
  properties: {
    friendlyName: config.avd.hostPoolFriendlyName
    hostPoolType : config.avd.hostPoolType
    loadBalancerType : config.avd.loadBalancerType
    preferredAppGroupType: config.avd.preferredAppGroupType
    validationEnvironment: true
    customRdpProperty: 'drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1'
    registrationInfo: {
      expirationTime: expirationTime
      // token: null
      registrationTokenOperation: 'Update'
    }
  }
}

// create WVD appgroup

resource ag 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = {
  name: config.avd.appGroupName
  location: location
  properties: {
      friendlyName: config.avd.appGroupFriendlyName
      applicationGroupType: config.avd.appGroupType
      hostPoolArmPath: hp.id
    }
  }

// create WVD workspace

resource ws 'Microsoft.DesktopVirtualization/workspaces@2022-04-01-preview' = {
  name: config.avd.workspaceName
  location: location
  properties: {
      friendlyName: config.avd.workspaceFriendlyName
      applicationGroupReferences: [ ag.id ]
  }
}

// deploy session hosts

module sessionHosts '../../../modules/vm.bicep' = [ for i in range(0, config.sessionHosts.count): {
  name: 'deploy-${config.avd.hostPoolName}-${config.sessionHosts.namePrefix}-${i}'
  params: {
    vNetName: baseConfig.hub.name
    sNetName: baseConfig.hub.subnets.dmzSubnet.name
    location: location
    vmName: '${config.sessionHosts.namePrefix}-${i}'
    vmSize: config.sessionHosts.vmSize
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    vmImageOffer: config.sessionHosts.vmImageOffer
    vmImageSku: config.sessionHosts.vmImageSku
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.aaddsAdminUsername
    domainPassword: domainConfig.defaultPassword
    hostPoolName: config.avd.hostPoolName
    hostPoolRegToken: hp.properties.registrationInfo.token
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}]
