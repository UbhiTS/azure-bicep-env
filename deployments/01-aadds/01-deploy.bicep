// deployment time ~35 mins
// + activation time ~35 mins
// = total time ~110 mins

// #################################################################################
// make sure your custom domain is registered in Azure AD before running this script
// #################################################################################

// #############################################################################
// make sure you run the below by signing-in with a admin@ubhims.onmicrosoft.com
// #############################################################################
// in case of service principal not found error:
// go to Azure AD Domain Services in the portal and delete the domain services instance
// follow: https://docs.microsoft.com/en-us/azure/active-directory-domain-services/alert-service-principal
// To recreate Service Principle, use Connect-MgGraph -Scopes "Application.ReadWrite.All" and then New-MgServicePrincipal -AppId "2565bd9d-da50-47d4-8b85-4c97f669dc36"
// For the Microsoft.AAD resource provider instead of "re-register", click "unregister" and then "register"

// NOTE* - After you deploy your domain, any user principal you will use to join VMs to the AD domain, needs to have the password reset in Azure AD
// https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-create-instance-advanced#enable-user-accounts-for-azure-ad-ds
// For cloud-only user accounts, users must change their passwords before they can use Azure AD DS. 
// This password change process causes the password hashes for Kerberos and NTLM authentication to be generated and stored in Azure AD. 
// The account isn't synchronized from Azure AD to Azure AD DS until the password is changed. 
// Either expire the passwords for all cloud users in the tenant who need to use Azure AD DS, which forces a password change on next sign-in, or instruct cloud users to manually change their passwords.


var baseConfigEastUS = loadJsonContent('../../base/config/base-eastus.json')
var baseConfigWestUS = loadJsonContent('../../base/config/base-westus.json')
var baseConfigSouthCentralUS = loadJsonContent('../../base/config/base-southcentralus.json')

var aaddsConfig = loadJsonContent('../../base/config/aadds.json')
var domainConfig = loadJsonContent('../../base/config/domain.json')


resource eastusHub 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: baseConfigEastUS.hub.name
  scope: resourceGroup(baseConfigEastUS.rg.name)
}

resource eastusHubAAADSSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: baseConfigEastUS.hub.subnets.aaddsSubnet.name
  parent: eastusHub
}

resource eastusDefaultNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: baseConfigEastUS.nsg.name
  scope: resourceGroup(baseConfigEastUS.rg.name)
}

resource westusDefaultNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: baseConfigWestUS.nsg.name
  scope: resourceGroup(baseConfigWestUS.rg.name)
}

resource southcentralusDefaultNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: baseConfigSouthCentralUS.nsg.name
  scope: resourceGroup(baseConfigSouthCentralUS.rg.name)
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

module eastusHubAADDSSubnetNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-eastus-hub-aadds-subnet-nsg-update'
  scope: resourceGroup(baseConfigEastUS.rg.name)
  dependsOn: [ aaddsNSG ]
  params:{
    config: baseConfigEastUS
    aaadsNsgId: aaddsNSG.outputs.id
    dmzNsgId: eastusDefaultNSG.id
  }
}

module aadds './modules/aadds.bicep' = {
  name: 'deploy-aadds'
  scope: resourceGroup(aaddsConfig.rg.name)
  dependsOn: [ aaddsNSG ]
  params:{
    baseConfig: baseConfigEastUS
    domainConfig: domainConfig
    aaddsConfig: aaddsConfig
    aaddsSubnetId: eastusHubAAADSSubnet.id
  }
}

module eastusHubDNSNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-eastus-hub-update'
  scope: resourceGroup(baseConfigEastUS.rg.name)
  dependsOn: [ aadds ]
  params:{
    config: baseConfigEastUS
    dnsServerIps: aadds.outputs.aaddsServerIps
    aaadsNsgId: aaddsNSG.outputs.id
    dmzNsgId: eastusDefaultNSG.id
  }
}

module westusHubDNSNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-westus-hub-update'
  scope: resourceGroup(baseConfigWestUS.rg.name)
  dependsOn: [ aadds ]
  params:{
    config: baseConfigWestUS
    dnsServerIps: aadds.outputs.aaddsServerIps
    dmzNsgId: westusDefaultNSG.id
  }
}

module southcentralusHubDNSNSGUpdate '../../modules/hub.bicep' = {
  name: 'deploy-southcentralus-hub-update'
  scope: resourceGroup(baseConfigSouthCentralUS.rg.name)
  dependsOn: [ aadds ]
  params:{
    config: baseConfigSouthCentralUS
    dnsServerIps: aadds.outputs.aaddsServerIps
    dmzNsgId: southcentralusDefaultNSG.id
  }
}
