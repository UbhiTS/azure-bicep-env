// Ensure you have given the domain user "Azure AD DC administrators" role

// NOTE* - After you deploy your domain, any user principal you will use to join VMs to the AD domain, needs to have the password reset in Azure AD
// https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-create-instance-advanced#enable-user-accounts-for-azure-ad-ds
// For cloud-only user accounts, users must change their passwords before they can use Azure AD DS. 
// This password change process causes the password hashes for Kerberos and NTLM authentication to be generated and stored in Azure AD. 
// The account isn't synchronized from Azure AD to Azure AD DS until the password is changed. 
// Either expire the passwords for all cloud users in the tenant who need to use Azure AD DS, which forces a password change on next sign-in, or instruct cloud users to manually change their passwords.


// -------------------------

var deployWestUS = false
var deploySouthCentralUS = false

// =========================



var baseConfigEastUS = loadJsonContent('../../base/config/base-eus.json')
var baseConfigWestUS = loadJsonContent('../../base/config/base-wus.json')
var baseConfigSouthCentralUS = loadJsonContent('../../base/config/base-scus.json')

var domainConfig = loadJsonContent('../../base/config/domain.json')

// vms

module eastusDMZVM '../../modules/vm.bicep' = {
  name: 'deploy-eastus-hub-dmz-vm'
  scope: resourceGroup(baseConfigEastUS.rg.name)
  params: {
    vNetName: baseConfigEastUS.hub.name
    sNetName: baseConfigEastUS.hub.subnets.aaddsSubnet.name
    location: baseConfigEastUS.rg.location
    vmName: 'eastus-dmz-vm1' // maxlength = 15
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    networkJoin: 'None'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

module westusDMZVM '../../modules/vm.bicep' = if (deployWestUS) {
  name: 'deploy-westus-hub-dmz-vm'
  scope: resourceGroup(baseConfigWestUS.rg.name)
  params: {
    vNetName: baseConfigWestUS.hub.name
    sNetName: baseConfigWestUS.hub.subnets.dmzSubnet.name
    location: baseConfigWestUS.rg.location
    vmName: 'westus-dmz-vm1' // maxlength = 15
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

module southcentralusDMZVM '../../modules/vm.bicep' = if (deploySouthCentralUS) {
  name: 'deploy-southcentralus-hub-dmz-vm'
  scope: resourceGroup(baseConfigSouthCentralUS.rg.name)
  params: {
    vNetName: baseConfigSouthCentralUS.hub.name
    sNetName: baseConfigSouthCentralUS.hub.subnets.dmzSubnet.name
    location: baseConfigSouthCentralUS.rg.location
    vmName: 'scus-dmz-vm1' // maxlength = 15
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

