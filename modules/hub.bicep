// dev
// ------------------------------------------------------------------------
// var config = loadJsonContent('../base/config/primary.json') // DEV
// param nsgId string
// ========================================================================

// prod
// ------------------------------------------------------------------------
param config object
param dmzNsgId string = ''
param aaadsNsgId string = ''
param dnsServerIps array = []
// ========================================================================


// #####################################################################################
// you cannot deploy subnets in parallel in Azure
// therefore to serialize the deployment, we've needed to add all subnets together below
// #####################################################################################

resource hub 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: config.hub.name
  location: config.rg.location
  properties: {
    addressSpace: {
      addressPrefixes: config.hub.addressPrefixes
    }
    dhcpOptions: {
      dnsServers: length(dnsServerIps) > 0 ? dnsServerIps : null
    }
    subnets: [
      {
        name: config.hub.subnets.aaddsSubnet.name
        properties: {
          addressPrefix: config.hub.subnets.aaddsSubnet.CIDR
          networkSecurityGroup: aaadsNsgId == '' ? null : { id: aaadsNsgId }
        }
      }
      {
        name: config.hub.subnets.gatewaySubnet.name
        properties: {
          addressPrefix: config.hub.subnets.gatewaySubnet.CIDR
        }
      }
      {
        name: config.hub.subnets.routeServerSubnet.name
        properties: {
          addressPrefix: config.hub.subnets.routeServerSubnet.CIDR
        }
      }
      {
        name: config.hub.subnets.azureFirewallSubnet.name
        properties: {
          addressPrefix: config.hub.subnets.azureFirewallSubnet.CIDR
        }
      }
      {
        name: config.hub.subnets.azureFirewallManagementSubnet.name
        properties: {
          addressPrefix: config.hub.subnets.azureFirewallManagementSubnet.CIDR
        }
      }
      {
        name: config.hub.subnets.azureBastionSubnet.name
        properties: {
          addressPrefix: config.hub.subnets.azureBastionSubnet.CIDR
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: config.hub.subnets.azureVirtualWANHub.name
        properties: {
          addressPrefix: config.hub.subnets.azureVirtualWANHub.CIDR
        }
      }
      {
        name: config.hub.subnets.dmzSubnet.name
        properties: {
          addressPrefix: config.hub.subnets.dmzSubnet.CIDR
          networkSecurityGroup: dmzNsgId == '' ? null : { id: dmzNsgId }
        }
      }
    ]
  }
}

output id string = hub.id
output name string = hub.name
