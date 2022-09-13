// Ensure you have given the domain user "Azure AD DC administrators" role

// NOTE* - After you deploy your domain, any user principal you will use to join VMs to the AD domain, needs to have the password reset in Azure AD
// https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-create-instance-advanced#enable-user-accounts-for-azure-ad-ds
// For cloud-only user accounts, users must change their passwords before they can use Azure AD DS. 
// This password change process causes the password hashes for Kerberos and NTLM authentication to be generated and stored in Azure AD. 
// The account isn't synchronized from Azure AD to Azure AD DS until the password is changed. 
// Either expire the passwords for all cloud users in the tenant who need to use Azure AD DS, which forces a password change on next sign-in, or instruct cloud users to manually change their passwords.


// -------------------------

var deployPrimary = true
var deploySecondary = true
var deployTertiary = true

// =========================



var baseConfigPrimary = loadJsonContent('../../base/config/base-primary.json')
var baseConfigSecondary = loadJsonContent('../../base/config/base-secondary.json')
var baseConfigTertiary = loadJsonContent('../../base/config/base-tertiary.json')

var domainConfig = loadJsonContent('../../base/config/domain.json')

// vms

module secondaryNVv3DMZVM '../../modules/vm.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-nvv3-hub-dmz-vm'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  params: {
    vNetName: baseConfigSecondary.hub.name
    sNetName: baseConfigSecondary.hub.subnets.dmzSubnet.name
    location: baseConfigSecondary.rg.location
    vmName: 'sec-dmz-gpu-vm1' // maxlength = 15
    vmSize: 'Standard_NV12s_v3'
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

module secondaryNVv4DMZVM '../../modules/vm.bicep' = if (deploySecondary) {
  name: 'deploy-secondary-nvv4-hub-dmz-vm'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  params: {
    vNetName: baseConfigSecondary.hub.name
    sNetName: baseConfigSecondary.hub.subnets.dmzSubnet.name
    location: baseConfigSecondary.rg.location
    vmName: 'sec-dmz-gpu-vm2' // maxlength = 15
    vmSize: 'Standard_NV32as_v4'
    networkJoin: 'AD'
    domainToJoin: domainConfig.domain
    domainUserName: domainConfig.adAdminUsername
    domainPassword: domainConfig.defaultPassword
    adminUsername: domainConfig.localVMAdminUsername
    adminPassword: domainConfig.defaultPassword
    autoShutDownNoticeEmail: domainConfig.defaultEmail
  }
}

// module tertiaryNVA10v5DMZVM '../../modules/vm.bicep' = if (deployTertiary) {
//   name: 'deploy-tertiary-nv10v5-hub-dmz-vm'
//   scope: resourceGroup(baseConfigTertiary.rg.name)
//   params: {
//     vNetName: baseConfigTertiary.hub.name
//     sNetName: baseConfigTertiary.hub.subnets.dmzSubnet.name
//     location: baseConfigTertiary.rg.location
//     vmName: 'ter-dmz-gpu-vm1' // maxlength = 15
//     vmSize: 'Standard_NV36ads_A10_v5'
//     networkJoin: 'AD'
//     domainToJoin: domainConfig.domain
//     domainUserName: domainConfig.adAdminUsername
//     domainPassword: domainConfig.defaultPassword
//     adminUsername: domainConfig.localVMAdminUsername
//     adminPassword: domainConfig.defaultPassword
//     autoShutDownNoticeEmail: domainConfig.defaultEmail
//   }
// }
