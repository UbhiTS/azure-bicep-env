param spokeName string
param spokeLocation string
param spokeAddressPrefix string
param nsgId string

param managementSubnetName string
param managementSubnetCIDR string
param workloadSubnetName string
param workloadSubnetCIDR string

resource spoke 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: spokeName
  location: spokeLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeAddressPrefix
      ]
    }
    subnets: [
      {
        name: managementSubnetName
        properties: {
          addressPrefix: managementSubnetCIDR
          networkSecurityGroup: {
            id: nsgId
          }
        }
      }
      {
        name: workloadSubnetName
        properties: {
          addressPrefix: workloadSubnetCIDR
        }
      }
    ]
  }
}

output vNet object = spoke
output id string = spoke.id
output name string = spoke.name
