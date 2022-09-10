param baseConfig object
param interHubRouteTableId string

resource azFWSubnetRTAttachment 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  name: '${baseConfig.hub.name}/${baseConfig.hub.subnets.azureFirewallSubnet.name}'
  properties: {
    addressPrefix: baseConfig.hub.subnets.azureFirewallSubnet.CIDR
    routeTable: {
      id: interHubRouteTableId
    }
  }
}
