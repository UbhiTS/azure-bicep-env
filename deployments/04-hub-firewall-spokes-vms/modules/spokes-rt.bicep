// dev
// ------------------------------------------------------------------------
// var config = loadJsonContent('../config/primary.json')
// param hubFWPvtIPAddress string
// ========================================================================

// prod
// ------------------------------------------------------------------------
param config object
param hubFWPvtIPAddress string
// ========================================================================

resource rt 'Microsoft.Network/routeTables@2022-01-01' = {
  name: 'secured-spoke-subnets-to-hub-nva-rt'
  location: config.rg.location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'all-${config.deploymentName}-spoke-traffic-to-hub-fw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: hubFWPvtIPAddress
          hasBgpOverride: false
        }
      } 
    ]
  }
}

output id string = rt.id
