var baseConfigEastUS = loadJsonContent('../../base/config/base-eus.json')
var domainConfig = loadJsonContent('../../base/config/domain.json')

module eastusDMZVM '../../modules/vm.bicep' = {
  name: 'deploy-eastus-hub-aadds-proxy-vm'
  scope: resourceGroup(baseConfigEastUS.rg.name)
  params: {
    vNetName: baseConfigEastUS.hub.name
    sNetName: baseConfigEastUS.hub.subnets.aaddsSubnet.name
    location: baseConfigEastUS.rg.location
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
