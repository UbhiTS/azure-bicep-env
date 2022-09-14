var appsConfig = {
  admin: loadJsonContent('../config/apps/admin.json')
  developer: loadJsonContent('../config/apps/developer.json')
  marketing: loadJsonContent('../config/apps/marketing.json')
  vip: loadJsonContent('../config/apps/vip.json')
}

param appGroupConfig object
param hostPoolId string

param location string = resourceGroup().location

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = {
  name: appGroupConfig.name
  location: location
  properties: {
    friendlyName: appGroupConfig.friendlyName
      applicationGroupType: appGroupConfig.type
      hostPoolArmPath: hostPoolId
  }
}

module appGroupApps './avd-app-group-apps.bicep' =  [for app in appGroupConfig.apps: if (appGroupConfig.type == 'RemoteApp') {
  name: 'deploy-${appGroupConfig.name}-apps-${app}'
  params: {
    appGroupName: appGroupConfig.name
    config: appsConfig[app]
  }
}]

output id string = appGroup.id
