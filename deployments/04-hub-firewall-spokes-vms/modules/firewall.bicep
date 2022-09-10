// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../../../base/config/primary.json')
// var config = loadJsonContent('../config/primary.json')
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param config object
// ========================================================================

param extHub1Name string
param extHub1SecuredSpokeAddresses array
param extHub2Name string
param extHub2SecuredSpokeAddresses array

var location = baseConfig.rg.location

var securedSpokeAddresses = [ config.spokes.spoke1.addressPrefix, config.spokes.spoke2.addressPrefix ]

resource hub 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: baseConfig.hub.name
  scope: resourceGroup(baseConfig.rg.name)
}

resource azFWSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: baseConfig.hub.subnets.azureFirewallSubnet.name
  parent: hub
}

resource fwPip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: config.firewall.pip.name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource fwDefaultPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' = {
  name: 'default'
  location: location
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Off'
    intrusionDetection: {
      mode: 'Off'
    }
    // insights: {
    //    isEnabled: true
    //    logAnalyticsResources: {
    //        defaultWorkspaceId: {
    //           id: log
    //        }
    //       workspaces: [
    //         {
    //           region: location
    //           workspaceId: {
    //             id: log
    //           }
    //         }
    //       ]
    //    }
    // }
  }
}

resource fwDefaultRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  name: 'DefaultApplicationRuleCollectionGroup'
  parent: fwDefaultPolicy
  properties: {
    priority: 7000
    ruleCollections: [
      
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'NetworkDefault'
        priority: 10000 // should be lower than App Rule Collection Group
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Inter-Spoke-Web-Traffic'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: securedSpokeAddresses
            destinationAddresses: securedSpokeAddresses
            destinationPorts: [ '80','443' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Spokes-To-${extHub1Name}-Hub-Web-Traffic'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: securedSpokeAddresses
            destinationAddresses: extHub1SecuredSpokeAddresses
            destinationPorts: [ '80','443' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Spokes-To-${extHub2Name}-Hub-Web-Traffic'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: securedSpokeAddresses
            destinationAddresses: extHub2SecuredSpokeAddresses
            destinationPorts: [ '80','443' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-${extHub1Name}-Hub-To-Spoke-Web-Traffic'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: extHub1SecuredSpokeAddresses
            destinationAddresses: securedSpokeAddresses
            destinationPorts: [ '80','443' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-${extHub2Name}-Hub-To-Spoke-Web-Traffic'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: extHub2SecuredSpokeAddresses
            destinationAddresses: securedSpokeAddresses
            destinationPorts: [ '80','443' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Inter-Spoke-Ping'
            ipProtocols: [ 'ICMP' ]
            sourceAddresses: securedSpokeAddresses
            destinationAddresses: securedSpokeAddresses
            destinationPorts: [ '*' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Spokes-To-${extHub1Name}-Hub-Ping'
            ipProtocols: [ 'ICMP' ]
            sourceAddresses: securedSpokeAddresses
            destinationAddresses: extHub1SecuredSpokeAddresses
            destinationPorts: [ '*' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Spokes-To-${extHub2Name}-Hub-Ping'
            ipProtocols: [ 'ICMP' ]
            sourceAddresses: securedSpokeAddresses
            destinationAddresses: extHub2SecuredSpokeAddresses
            destinationPorts: [ '*' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-${extHub1Name}-Hub-To-Spoke-Ping'
            ipProtocols: [ 'ICMP' ]
            sourceAddresses: extHub1SecuredSpokeAddresses
            destinationAddresses: securedSpokeAddresses
            destinationPorts: [ '*' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-${extHub2Name}-Hub-To-Spoke-Ping'
            ipProtocols: [ 'ICMP' ]
            sourceAddresses: extHub2SecuredSpokeAddresses
            destinationAddresses: securedSpokeAddresses
            destinationPorts: [ '*' ]
          }
        ]
      }

      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'ApplicationDefault'
        priority: 15000
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Allow_WebBrowsing'
            description: 'Browsing - Allow Search Engines & News'
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            sourceAddresses: securedSpokeAddresses // allow traffic only from the secured spokes through this firewall
            webCategories: [ 
              'SearchEnginesAndPortals'
              'ComputersAndTechnology'
              'Business'
            ]
          }
        ]
      }

    ]
  }
}

resource azFW 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: config.firewall.firewall.name
  location: location
  zones: null
  properties: {
    ipConfigurations: [
      {
        name: 'ipConf'
        properties: {
            publicIPAddress: {
              id: fwPip.id
            }
            subnet: {
                id: azFWSubnet.id
            }
        }
      }
    ]
    sku: {
      tier: 'Premium'
    }
    firewallPolicy: {
        id: fwDefaultPolicy.id
    }
  }  
}

output azFWPvtIPAddress string = azFW.properties.ipConfigurations[0].properties.privateIPAddress
