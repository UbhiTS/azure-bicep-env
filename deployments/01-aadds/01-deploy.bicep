// deployment time ~35 mins

// in case of service principal not found error:
// go to Azure AD Domain Services in the portal and delete the domain services instance
// follow: https://docs.microsoft.com/en-us/azure/active-directory-domain-services/alert-service-principal
// but instead of "re-register", click "unregister" and then "register"

// NOTE* - After you deploy your domain, any user principal you will use to join VMs to the AD domain, needs to have the password reset in Azure AD
// https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-create-instance-advanced#enable-user-accounts-for-azure-ad-ds
// For cloud-only user accounts, users must change their passwords before they can use Azure AD DS. 
// This password change process causes the password hashes for Kerberos and NTLM authentication to be generated and stored in Azure AD. 
// The account isn't synchronized from Azure AD to Azure AD DS until the password is changed. 
// Either expire the passwords for all cloud users in the tenant who need to use Azure AD DS, which forces a password change on next sign-in, or instruct cloud users to manually change their passwords.


var baseConfigPrimary = loadJsonContent('../../base/config/base-primary.json')
var baseConfigSecondary = loadJsonContent('../../base/config/base-secondary.json')
var baseConfigTertiary = loadJsonContent('../../base/config/base-tertiary.json')

var aaddsConfig = loadJsonContent('../../base/config/aadds.json')
var domainConfig = loadJsonContent('../../base/config/domain.json')


resource primaryHub 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: baseConfigPrimary.hub.name
  scope: resourceGroup(baseConfigPrimary.rg.name)
}

resource primaryHubAAADSSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: baseConfigPrimary.hub.subnets.aaddsSubnet.name
  parent: primaryHub
}

resource primaryDefaultNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: baseConfigPrimary.nsg.name
  scope: resourceGroup(baseConfigPrimary.rg.name)
}

resource secondaryDefaultNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: baseConfigSecondary.nsg.name
  scope: resourceGroup(baseConfigSecondary.rg.name)
}

resource tertiaryDefaultNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: baseConfigTertiary.nsg.name
  scope: resourceGroup(baseConfigTertiary.rg.name)
}

module aaddsRG '../../modules/rg.bicep' = {
  name: 'deploy-aadds-rg'
  scope: subscription()
  params: {
    config: aaddsConfig
  }
}

module aaddsNSG './modules/nsg-aadds.bicep' = {
  name: 'deploy-aadds-nsg'
  dependsOn: [ aaddsRG ]
  scope: resourceGroup(aaddsConfig.rg.name)
  params: {
    aaddsConfig: aaddsConfig
  }
}

module primaryHubAADDSSubnetNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-primary-hub-aadds-subnet-nsg-update'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  dependsOn: [ aaddsNSG ]
  params:{
    config: baseConfigPrimary
    aaadsNsgId: aaddsNSG.outputs.id
    dmzNsgId: primaryDefaultNSG.id
  }
}

module aadds './modules/aadds.bicep' = {
  name: 'deploy-aadds'
  scope: resourceGroup(aaddsConfig.rg.name)
  dependsOn: [ aaddsNSG ]
  params:{
    baseConfig: baseConfigPrimary
    domainConfig: domainConfig
    aaddsConfig: aaddsConfig
    aaddsSubnetId: primaryHubAAADSSubnet.id
  }
}

module primaryHubDNSNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-primary-hub-update'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  dependsOn: [ aadds ]
  params:{
    config: baseConfigPrimary
    dnsServerIps: aadds.outputs.aaddsServerIps
    aaadsNsgId: aaddsNSG.outputs.id
    dmzNsgId: primaryDefaultNSG.id
  }
}

module secondaryHubDNSNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-secondary-hub-update'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  dependsOn: [ aadds ]
  params:{
    config: baseConfigSecondary
    dnsServerIps: aadds.outputs.aaddsServerIps
    dmzNsgId: secondaryDefaultNSG.id
  }
}

module tertiaryHubDNSNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-tertiary-hub-update'
  scope: resourceGroup(baseConfigTertiary.rg.name)
  dependsOn: [ aadds ]
  params:{
    config: baseConfigTertiary
    dnsServerIps: aadds.outputs.aaddsServerIps
    dmzNsgId: tertiaryDefaultNSG.id
  }
}
