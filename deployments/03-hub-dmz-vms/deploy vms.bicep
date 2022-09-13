// Ensure you have given the domain user "Azure AD DC administrators" role

// NOTE* - After you deploy your domain, any user principal you will use to join VMs to the AD domain, needs to have the password reset in Azure AD
// https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-create-instance-advanced#enable-user-accounts-for-azure-ad-ds
// For cloud-only user accounts, users must change their passwords before they can use Azure AD DS. 
// This password change process causes the password hashes for Kerberos and NTLM authentication to be generated and stored in Azure AD. 
// The account isn't synchronized from Azure AD to Azure AD DS until the password is changed. 
// Either expire the passwords for all cloud users in the tenant who need to use Azure AD DS, which forces a password change on next sign-in, or instruct cloud users to manually change their passwords.


// -------------------------

var deploySecondary = true
var deployTertiary = true

// =========================



var baseConfigPrimary = loadJsonContent('../../base/config/base-primary.json')
var baseConfigSecondary = loadJsonContent('../../base/config/base-secondary.json')
var baseConfigTertiary = loadJsonContent('../../base/config/base-tertiary.json')

var domainConfig = loadJsonContent('../../base/config/domain.json')

// vms

module primaryDMZVM '../../modules/vm.bicep' = {
  name: 'deploy-primary-hub-dmz-vm'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  params: {
    vNetName: baseConfigPrimary.hub.name
    sNetName: baseConfigPrimary.hub.subnets.dmzSubnet.name
    location: baseConfigPrimary.rg.location
    vmName: 'pri-dmz-vm1' // maxlength = 15
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

module secondaryDMZVM '../../modules/vm.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-hub-dmz-vm'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  params: {
    vNetName: baseConfigSecondary.hub.name
    sNetName: baseConfigSecondary.hub.subnets.dmzSubnet.name
    location: baseConfigSecondary.rg.location
    vmName: 'sec-dmz-vm1' // maxlength = 15
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

module tertiaryDMZVM '../../modules/vm.bicep' = if (deployTertiary) {
  name: 'deploy-tertiary-hub-dmz-vm'
  scope: resourceGroup(baseConfigTertiary.rg.name)
  params: {
    vNetName: baseConfigTertiary.hub.name
    sNetName: baseConfigTertiary.hub.subnets.dmzSubnet.name
    location: baseConfigTertiary.rg.location
    vmName: 'ter-dmz-vm1' // maxlength = 15
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

