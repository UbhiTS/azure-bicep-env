// resource vngPIP 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
//   name: vngPIPName
//   location: location
//   tags: {
//     createdDate: date
//     Owner: email
//   }
//   sku: {
//     name: 'Basic'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Dynamic'
//   }
// }

// resource vng 'Microsoft.Network/virtualNetworkGateways@2021-03-01' = {
//   name: vngName
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'ipConf'
//         properties: {
//           privateIPAllocationMethod: 'Dynamic'
//           subnet: {
//             id: '${virtualNetwork.id}/subnets/GatewaySubnet'
//           }
//           publicIPAddress: {
//             id: vngPIP.id
//           }
//         }
//       }
//     ]
//     sku: {
//       name: 'VpnGw1'
//       tier: 'VpnGw1'
//     }
//     gatewayType: 'Vpn'
//     vpnType: 'RouteBased'
//     enableBgp: false
//   }
// }
