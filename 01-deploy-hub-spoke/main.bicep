// Visual Subnetter : https://subn.dev/#

targetScope = 'subscription'

var params = loadJsonContent('../params.json')

resource primaryRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: params.primaryRGName
  location: params.primaryRGLocation
}

resource secondaryRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: params.secondaryRGName
  location: params.secondaryRGLocation
}

module primaryHubSpoke './networking/hubSpokes.bicep' = {
  name: 'primaryHubSpokeDeployment'
  scope: primaryRG
  params: {
    nsgName: params.primaryNetwork.nsgName
    hubName: params.primaryNetwork.hub.name
    hubAddressPrefix: params.primaryNetwork.hub.addressPrefix
    hubDMZSubnetName: params.primaryNetwork.hub.dmzSubnetName
    hubDMZSubnetCIDR: params.primaryNetwork.hub.dmzSubnetCIDR
    hubGatewaySubnetName: params.primaryNetwork.hub.gatewaySubnetName
    hubGatewaySubnetCIDR: params.primaryNetwork.hub.gatewaySubnetCIDR
    hubRouteServerSubnetName: params.primaryNetwork.hub.routeServerSubnetName
    hubRouteServerSubnetCIDR: params.primaryNetwork.hub.routeServerSubnetCIDR
    hubAzureFirewallSubnetName: params.primaryNetwork.hub.azureFirewallSubnetName
    hubAzureFirewallSubnetCIDR: params.primaryNetwork.hub.azureFirewallSubnetCIDR
    hubAzureFirewallManagementSubnetName: params.primaryNetwork.hub.azureFirewallManagementSubnetName
    hubAzureFirewallManagementSubnetCIDR: params.primaryNetwork.hub.azureFirewallManagementSubnetCIDR
    hubAzureBastionSubnetName: params.primaryNetwork.hub.azureBastionSubnetName
    hubAzureBastionSubnetCIDR: params.primaryNetwork.hub.azureBastionSubnetCIDR
    hubAzureVirtualWANHubName: params.primaryNetwork.hub.azureVirtualWANHubName
    hubAzureVirtualWANHubCIDR: params.primaryNetwork.hub.azureVirtualWANHubCIDR

    spoke1Name: params.primaryNetwork.spoke1.name
    spoke1AddressPrefix: params.primaryNetwork.spoke1.addressPrefix
    spoke1ManagementSubnetName: params.primaryNetwork.spoke1.managementSubnetName
    spoke1ManagementSubnetCIDR: params.primaryNetwork.spoke1.managementSubnetCIDR
    spoke1WorkloadSubnetName: params.primaryNetwork.spoke1.workloadSubnetName
    spoke1WorkloadSubnetCIDR: params.primaryNetwork.spoke1.workloadSubnetCIDR

    spoke2Name: params.primaryNetwork.spoke2.name
    spoke2AddressPrefix: params.primaryNetwork.spoke2.addressPrefix
    spoke2ManagementSubnetName: params.primaryNetwork.spoke2.managementSubnetName
    spoke2ManagementSubnetCIDR: params.primaryNetwork.spoke2.managementSubnetCIDR
    spoke2WorkloadSubnetName: params.primaryNetwork.spoke2.workloadSubnetName
    spoke2WorkloadSubnetCIDR: params.primaryNetwork.spoke2.workloadSubnetCIDR
  }
}

module secondaryHubSpoke './networking/hubSpokes.bicep' = {
  name: 'secondaryHubSpokeDeployment'
  scope: secondaryRG
  params: {
    nsgName: params.secondaryNetwork.nsgName
    hubName: params.secondaryNetwork.hub.name
    hubAddressPrefix: params.secondaryNetwork.hub.addressPrefix
    hubDMZSubnetName: params.secondaryNetwork.hub.dmzSubnetName
    hubDMZSubnetCIDR: params.secondaryNetwork.hub.dmzSubnetCIDR
    hubGatewaySubnetName: params.secondaryNetwork.hub.gatewaySubnetName
    hubGatewaySubnetCIDR: params.secondaryNetwork.hub.gatewaySubnetCIDR
    hubRouteServerSubnetName: params.secondaryNetwork.hub.routeServerSubnetName
    hubRouteServerSubnetCIDR: params.secondaryNetwork.hub.routeServerSubnetCIDR
    hubAzureFirewallSubnetName: params.secondaryNetwork.hub.azureFirewallSubnetName
    hubAzureFirewallSubnetCIDR: params.secondaryNetwork.hub.azureFirewallSubnetCIDR
    hubAzureFirewallManagementSubnetName: params.secondaryNetwork.hub.azureFirewallManagementSubnetName
    hubAzureFirewallManagementSubnetCIDR: params.secondaryNetwork.hub.azureFirewallManagementSubnetCIDR
    hubAzureBastionSubnetName: params.secondaryNetwork.hub.azureBastionSubnetName
    hubAzureBastionSubnetCIDR: params.secondaryNetwork.hub.azureBastionSubnetCIDR
    hubAzureVirtualWANHubName: params.secondaryNetwork.hub.azureVirtualWANHubName
    hubAzureVirtualWANHubCIDR: params.secondaryNetwork.hub.azureVirtualWANHubCIDR

    spoke1Name: params.secondaryNetwork.spoke1.name
    spoke1AddressPrefix: params.secondaryNetwork.spoke1.addressPrefix
    spoke1ManagementSubnetName: params.secondaryNetwork.spoke1.managementSubnetName
    spoke1ManagementSubnetCIDR: params.secondaryNetwork.spoke1.managementSubnetCIDR
    spoke1WorkloadSubnetName: params.secondaryNetwork.spoke1.workloadSubnetName
    spoke1WorkloadSubnetCIDR: params.secondaryNetwork.spoke1.workloadSubnetCIDR

    spoke2Name: params.secondaryNetwork.spoke2.name
    spoke2AddressPrefix: params.secondaryNetwork.spoke2.addressPrefix
    spoke2ManagementSubnetName: params.secondaryNetwork.spoke2.managementSubnetName
    spoke2ManagementSubnetCIDR: params.secondaryNetwork.spoke2.managementSubnetCIDR
    spoke2WorkloadSubnetName: params.secondaryNetwork.spoke2.workloadSubnetName
    spoke2WorkloadSubnetCIDR: params.secondaryNetwork.spoke2.workloadSubnetCIDR
  }
}

module primaryVNetPeerings './networking/peeringsHubSpoke.bicep' = {
  name: 'primaryVnetPeeringsDeployment'
  dependsOn: [ primaryHubSpoke ]
  scope: resourceGroup(primaryRG.name)
  params: {
    hubVNetId: primaryHubSpoke.outputs.hubVNetId
    hubVNetName: primaryHubSpoke.outputs.hubVNetName
    spokeVNet1Id: primaryHubSpoke.outputs.spokeVNet1Id
    spokeVNet1Name: primaryHubSpoke.outputs.spokeVNet1Name
    spokeVNet2Id: primaryHubSpoke.outputs.spokeVNet2Id
    spokeVNet2Name: primaryHubSpoke.outputs.spokeVNet2Name
  }
}

module secondaryVNetPeerings './networking/peeringsHubSpoke.bicep' = {
  name: 'secondaryVNetPeeringsDeployment'
  dependsOn: [ secondaryHubSpoke ]
  scope: resourceGroup(secondaryRG.name)
  params: {
    hubVNetId: secondaryHubSpoke.outputs.hubVNetId
    hubVNetName: secondaryHubSpoke.outputs.hubVNetName
    spokeVNet1Id: secondaryHubSpoke.outputs.spokeVNet1Id
    spokeVNet1Name: secondaryHubSpoke.outputs.spokeVNet1Name
    spokeVNet2Id: secondaryHubSpoke.outputs.spokeVNet2Id
    spokeVNet2Name: secondaryHubSpoke.outputs.spokeVNet2Name
  }
}


module interHubNetworkPeerings './networking/peeringsInterHub.bicep' = {
  name: 'interHubNetworkPeeringsDeployment'
  dependsOn: [ primaryHubSpoke, secondaryHubSpoke ]
  scope: resourceGroup(primaryRG.name)
  params: {
    primaryHubVNetId: primaryHubSpoke.outputs.hubVNetId
    primaryHubVNetName: primaryHubSpoke.outputs.hubVNetName
    primaryHubVNetRGName: primaryRG.name
    secondaryHubVNetId: secondaryHubSpoke.outputs.hubVNetId
    secondaryHubVNetName: secondaryHubSpoke.outputs.hubVNetName
    secondaryHubVNetRGName: secondaryRG.name
  }
}
