var baseConfigPrimary = loadJsonContent('../../base/config/base-primary.json')
var domainConfig = loadJsonContent('../../base/config/domain.json')

module primaryDMZVM '../../modules/vm.bicep' = {
  name: 'deploy-primary-hub-aadds-proxy-vm'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  params: {
    vNetName: baseConfigPrimary.hub.name
    sNetName: baseConfigPrimary.hub.subnets.aaddsSubnet.name
    location: baseConfigPrimary.rg.location
    vmName: 'aadds-proxy-vm' // maxlength = 15
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

