param hubName string
param hubLocation string
param hubAddressPrefix string
param nsgId string

param dmzSubnetName string
param dmzSubnetCIDR string
param GatewaySubnetName string
param GatewaySubnetCIDR string
param RouteServerSubnetName string
param RouteServerSubnetCIDR string
param AzureFirewallSubnetName string
param AzureFirewallSubnetCIDR string
param AzureFirewallManagementSubnetName string
param AzureFirewallManagementSubnetCIDR string
param AzureBastionSubnetName string
param AzureBastionSubnetCIDR string
param AzureVirtualWANHubName string
param AzureVirtualWANHubCIDR string

resource hub 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: hubName
  location: hubLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressPrefix

      ]
    }
    subnets: [
      {
        name: dmzSubnetName
        properties: {
          addressPrefix: dmzSubnetCIDR
          networkSecurityGroup: {
            id: nsgId
          }
        }
      }
      {
        name: GatewaySubnetName
        properties: {
          addressPrefix: GatewaySubnetCIDR
        }
      }
      {
        name: RouteServerSubnetName
        properties: {
          addressPrefix: RouteServerSubnetCIDR
        }
      }
      {
        name: AzureFirewallSubnetName
        properties: {
          addressPrefix: AzureFirewallSubnetCIDR
        }
      }
      {
        name: AzureFirewallManagementSubnetName
        properties: {
          addressPrefix: AzureFirewallManagementSubnetCIDR
        }
      }
      {
        name: AzureBastionSubnetName
        properties: {
          addressPrefix: AzureBastionSubnetCIDR
        }
      }
      {
        name: AzureVirtualWANHubName
        properties: {
          addressPrefix: AzureVirtualWANHubCIDR
        }
      }
    ]
  }
}

output vNet object = hub
output id string = hub.id
output name string = hub.name
