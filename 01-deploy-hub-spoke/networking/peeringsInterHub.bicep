param primaryHubVNetId string
param primaryHubVNetName string
param primaryHubVNetRGName string
param secondaryHubVNetId string
param secondaryHubVNetName string
param secondaryHubVNetRGName string

module peerPrimaryHubToSecondaryHub './components/peering.bicep' = {
  name: 'peerPrimaryHubToSecondaryHub'
  scope: resourceGroup(primaryHubVNetRGName)
  params: {
    localVNetName: primaryHubVNetName
    remoteVNetName: secondaryHubVNetName
    remoteVNetId: secondaryHubVNetId
  }
}

module peerSecondaryHubToPrimaryHub './components/peering.bicep' = {
  name: 'peerSecondaryHubToPrimaryHub'
  scope: resourceGroup(secondaryHubVNetRGName)
  params: {
    localVNetName: secondaryHubVNetName
    remoteVNetId: primaryHubVNetId
    remoteVNetName: primaryHubVNetName
  }
}
