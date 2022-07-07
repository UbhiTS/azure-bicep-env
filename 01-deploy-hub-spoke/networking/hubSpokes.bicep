var rg = resourceGroup()

param nsgName string

param hubName string
param hubAddressPrefix string
param hubDMZSubnetName string
param hubDMZSubnetCIDR string
param hubGatewaySubnetName string
param hubGatewaySubnetCIDR string
param hubRouteServerSubnetName string
param hubRouteServerSubnetCIDR string
param hubAzureFirewallSubnetName string
param hubAzureFirewallSubnetCIDR string
param hubAzureFirewallManagementSubnetName string
param hubAzureFirewallManagementSubnetCIDR string
param hubAzureBastionSubnetName string
param hubAzureBastionSubnetCIDR string
param hubAzureVirtualWANHubName string
param hubAzureVirtualWANHubCIDR string

param spoke1Name string
param spoke1AddressPrefix string
param spoke1ManagementSubnetName string
param spoke1WorkloadSubnetName string
param spoke1ManagementSubnetCIDR string
param spoke1WorkloadSubnetCIDR string

param spoke2Name string
param spoke2AddressPrefix string
param spoke2ManagementSubnetName string
param spoke2WorkloadSubnetName string
param spoke2ManagementSubnetCIDR string
param spoke2WorkloadSubnetCIDR string


module hubNSG './components/nsg.bicep' = {
  name: 'nsgDeployment'
  scope: rg
  params: {
    nsgName: nsgName
    nsgLocation: rg.location
  }
}

module hubVNet './components/hub.bicep' = {
  name: 'hubVNetDeployment'
  scope: rg
  dependsOn: [ hubNSG ]
  params: {
    hubName: hubName
    hubLocation: rg.location
    hubAddressPrefix: hubAddressPrefix
    nsgId: hubNSG.outputs.id
    
    dmzSubnetName: hubDMZSubnetName
    dmzSubnetCIDR: hubDMZSubnetCIDR
    GatewaySubnetName: hubGatewaySubnetName
    GatewaySubnetCIDR: hubGatewaySubnetCIDR
    RouteServerSubnetName: hubRouteServerSubnetName
    RouteServerSubnetCIDR: hubRouteServerSubnetCIDR
    AzureFirewallSubnetName: hubAzureFirewallSubnetName
    AzureFirewallSubnetCIDR: hubAzureFirewallSubnetCIDR
    AzureFirewallManagementSubnetName: hubAzureFirewallManagementSubnetName
    AzureFirewallManagementSubnetCIDR: hubAzureFirewallManagementSubnetCIDR
    AzureBastionSubnetName: hubAzureBastionSubnetName
    AzureBastionSubnetCIDR: hubAzureBastionSubnetCIDR
    AzureVirtualWANHubName: hubAzureVirtualWANHubName
    AzureVirtualWANHubCIDR: hubAzureVirtualWANHubCIDR
  }
}

module spokeVNet1 './components/spoke.bicep' = {
  name: 'spoke1VNetDeployment'
  scope: rg
  dependsOn: [ hubNSG ]
  params: {
    spokeName: spoke1Name
    spokeLocation: rg.location
    spokeAddressPrefix: spoke1AddressPrefix
    nsgId: hubNSG.outputs.id
    
    managementSubnetName: spoke1ManagementSubnetName
    managementSubnetCIDR: spoke1ManagementSubnetCIDR
    workloadSubnetName: spoke1WorkloadSubnetName
    workloadSubnetCIDR: spoke1WorkloadSubnetCIDR
  }
}

module spokeVNet2 './components/spoke.bicep' = {
  name: 'spoke2VNetDeployment'
  scope: rg
  dependsOn: [ hubNSG ]
  params: {
    spokeName: spoke2Name
    spokeLocation: rg.location
    spokeAddressPrefix: spoke2AddressPrefix
    nsgId: hubNSG.outputs.id
    
    managementSubnetName: spoke2ManagementSubnetName
    managementSubnetCIDR: spoke2ManagementSubnetCIDR
    workloadSubnetName: spoke2WorkloadSubnetName
    workloadSubnetCIDR: spoke2WorkloadSubnetCIDR
  }
}

output hubVNet object = hubVNet.outputs.vNet
output hubVNetId string = hubVNet.outputs.id
output hubVNetName string = hubVNet.outputs.name

output spokeVNet1 object = spokeVNet1.outputs.vNet
output spokeVNet1Id string = spokeVNet1.outputs.id
output spokeVNet1Name string = spokeVNet1.outputs.name

output spokeVNet2 object = spokeVNet2.outputs.vNet
output spokeVNet2Id string = spokeVNet2.outputs.id
output spokeVNet2Name string = spokeVNet2.outputs.name
