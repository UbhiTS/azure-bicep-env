// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../../../base/config/primary.json')
// var aaddsConfig = loadJsonContent('../../../base/config/aadds.json')
// var domainConfig = loadJsonContent('../../../base/config/domain.json')
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param aaddsConfig object
param domainConfig object
// ========================================================================

param aaddsSubnetId string

var location = baseConfig.rg.location

resource aadds 'Microsoft.AAD/domainServices@2021-05-01' = {
  name: domainConfig.domain
  location: location
  properties: {
    domainName: domainConfig.domain
    filteredSync: 'Disabled'
    domainConfigurationType: 'FullySynced'
    
    notificationSettings: {
      additionalRecipients: aaddsConfig.notificationRecipients
      notifyDcAdmins: 'Enabled'
      notifyGlobalAdmins: 'Enabled'
    }

    replicaSets: [
      {
        location: location
        subnetId: aaddsSubnetId
      }
    ]

    domainSecuritySettings: {
      kerberosArmoring: 'Disabled'
      kerberosRc4Encryption: 'Enabled'
      ntlmV1: 'Disabled'
      //syncKerberosPasswords: 'string'
      syncNtlmPasswords: 'Enabled'
      syncOnPremPasswords: 'Enabled'
      tlsV1: 'Enabled'
    }
    
    sku: 'Standard'
  }
}

output aaddsServerIps array = aadds.properties.replicaSets[0].domainControllerIpAddress
