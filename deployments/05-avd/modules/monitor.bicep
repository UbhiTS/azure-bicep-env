// var baseConfig = loadJsonContent('../../../base/config/primary.json')
// // var baseConfigSecondary = loadJsonContent('../../../base/config/secondary.json')
// // var baseConfigTertiary = loadJsonContent('../../../base/config/tertiary.json')

// var config = loadJsonContent('../config/primary.json')
// // var configSecondary = loadJsonContent('../config/secondary.json')
// // var configTertiary = loadJsonContent('../config/tertiary.json')

// var location = config.rg.location

//Create Azure Log Analytics Workspace
// module wvdmonitor './1.4. wvd-LogAnalytics.bicep' = {
//   name : 'LAWorkspace'
//   scope: resourceGroup(logAnalyticsResourceGroup)
//   params: {
//     logAnalyticsWorkspaceName : logAnalyticsWorkspaceName
//     logAnalyticslocation : logAnalyticslocation
//     logAnalyticsWorkspaceSku : logAnalyticsWorkspaceSku
//     hostpoolName : hp.name
//     workspaceName : ws.name
//     logAnalyticsResourceGroup : logAnalyticsResourceGroup
//     wvdBackplaneResourceGroup : wvdBackplaneResourceGroup
//   }
// }

// resource wvdla 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
//   name : config.logAnalytics.workspaceName
//   location : location
//   properties : {
//     sku: {
//       name : config.logAnalytics.workspaceSku
//     }
//   }
// }


// var hostpoolDiagName = '${config.avd.hostPoolName}/Microsoft.Insights/hostpool-diag'
// var workspaceDiagName = '${config.logAnalytics.workspaceName}/Microsoft.Insights/workspacepool-diag'

// //Create diagnostic settings for WVD Objects
// resource wvdhpds 'Microsoft.DesktopVirtualization/hostpools/providers/diagnosticSettings@2017-05-01-preview' = {
//   name : hostpoolDiagName
//   location : location
//   properties : {
//     workspaceId: logAnalyticsWorkspaceID
//     logs : [
//       {
//       category : 'Checkpoint'
//       enabled: 'True'
//       }
//       {
//         category : 'Error'
//         enabled: 'True'
//       }
//       {
//         category : 'Management'
//         enabled: 'True'
//       }
//       {
//         category : 'Connection'
//         enabled: 'True'
//       }      
//       {
//         category : 'HostRegistration'
//         enabled: 'True'
//       }   
//     ]
//   }
// }

// resource wvdwsds 'Microsoft.DesktopVirtualization/workspaces/providers/diagnosticSettings@2017-05-01-preview' = {
//   name : workspaceDiagName
//   location : location
//   properties : {
//     workspaceId: logAnalyticsWorkspaceID
//     logs : [
//       {
//       category : 'Checkpoint'
//       enabled: 'True'
//       }
//       {
//         category : 'Error'
//         enabled: 'True'
//       }
//       {
//         category : 'Management'
//         enabled: 'True'
//       }
//       {
//         category : 'Feed'
//         enabled: 'True'
//       }      
//     ]
//   }
// }
