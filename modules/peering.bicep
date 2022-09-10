
param localVNetName string
param remoteVNetName string
param remoteVNetId string

resource localVNetToRemoteVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${localVNetName}/peering-to-${remoteVNetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVNetId
    }
  }
}

output id string = localVNetToRemoteVnetPeering.id
output name string = localVNetToRemoteVnetPeering.name
