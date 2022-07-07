var rg = resourceGroup()

param hubVNetId string
param hubVNetName string
param spokeVNet1Id string
param spokeVNet1Name string
param spokeVNet2Id string
param spokeVNet2Name string

module peerHubToSpoke1 './components/peering.bicep' = {
  name: 'peerHubToSpoke1'
  scope: rg
  params: {
    localVNetName: hubVNetName
    remoteVNetName: spokeVNet1Name
    remoteVNetId: spokeVNet1Id
  }
}

module peerSpoke1ToHub './components/peering.bicep' = {
  name: 'peerSpoke1ToHub'
  scope: rg
  params: {
    localVNetName: spokeVNet1Name
    remoteVNetName: hubVNetName
    remoteVNetId: hubVNetId
  }
}

module peerHubToSpoke2 './components/peering.bicep' = {
  name: 'peerHubToSpoke2'
  scope: rg
  params: {
    localVNetName: hubVNetName
    remoteVNetName: spokeVNet2Name
    remoteVNetId: spokeVNet2Id
  }
}

module peerSpoke2ToHub './components/peering.bicep' = {
  name: 'peerSpoke2ToHub'
  scope: rg
  params: {
    localVNetName: spokeVNet2Name
    remoteVNetName: hubVNetName
    remoteVNetId: hubVNetId
  }
}
