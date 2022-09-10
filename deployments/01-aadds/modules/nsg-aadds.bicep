// dev
// ------------------------------------------------------------------------
// var aaddsConfig = loadJsonContent('../../../base/config/aadds.json')
// ========================================================================

// prod
// ------------------------------------------------------------------------
param aaddsConfig object
// ========================================================================


resource aaddsNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: aaddsConfig.nsg.name
  location: aaddsConfig.rg.location
  properties: {
    securityRules: [
      {
        name: 'AllowPSRemoting'
        properties: {
          access: 'Allow'
          priority: 301
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureActiveDirectoryDomainServices'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '5986'
        }
      }
      {
        name: 'AllowRD'
        properties: {
          access: 'Allow'
          priority: 201
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'CorpNetSaw'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

output id string = aaddsNSG.id
output name string = aaddsNSG.name
