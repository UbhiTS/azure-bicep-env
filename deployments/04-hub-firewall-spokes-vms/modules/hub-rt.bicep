// dev
// ------------------------------------------------------------------------
// var baseConfig = loadJsonContent('../../../base/config/primary.json')
// var config = loadJsonContent('../config/primary.json')
// var extHub1Config = loadJsonContent('../config/secondary.json')
// var extHub1FWPvtIpAddress = ''
// var extHub2Config = loadJsonContent('../config/tertiary.json')
// var extHub2FWPvtIpAddress = ''
// ========================================================================

// prod
// ------------------------------------------------------------------------
param baseConfig object
param config object
param extHub1Config object
param extHub1FWPvtIpAddress string
param extHub2Config object
param extHub2FWPvtIpAddress string
// ========================================================================


resource rt 'Microsoft.Network/routeTables@2022-01-01' = {
  name: 'ubhims-${config.deploymentName}-fw-rt'
  location: baseConfig.rg.location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'all-traffic-to-${extHub1Config.deploymentName}-hub-spoke1-forward-to-${extHub1Config.deploymentName}-hub-nva'
        properties: {
          addressPrefix: extHub1Config.spokes.spoke1.addressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: extHub1FWPvtIpAddress
          hasBgpOverride: false
        }
      }
      {
        name: 'all-traffic-to-${extHub1Config.deploymentName}-hub-spoke2-forward-to-${extHub1Config.deploymentName}-hub-nva'
        properties: {
          addressPrefix: extHub1Config.spokes.spoke2.addressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: extHub1FWPvtIpAddress
          hasBgpOverride: false
        }
      } 
      {
        name: 'all-traffic-to-${extHub2Config.deploymentName}-hub-spoke1-forward-to-${extHub2Config.deploymentName}-hub-nva'
        properties: {
          addressPrefix: extHub2Config.spokes.spoke1.addressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: extHub2FWPvtIpAddress
          hasBgpOverride: false
        }
      }
      {
        name: 'all-traffic-to-${extHub2Config.deploymentName}-hub-spoke2-forward-to-${extHub2Config.deploymentName}-hub-nva'
        properties: {
          addressPrefix: extHub2Config.spokes.spoke2.addressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: extHub2FWPvtIpAddress
          hasBgpOverride: false
        }
      } 
    ]
  }
}

output id string = rt.id
