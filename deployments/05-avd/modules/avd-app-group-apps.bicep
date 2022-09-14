//var config = loadJsonContent('../config/applications/admin.json')
param config array
param appGroupName string

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' existing = {
  name: appGroupName
}

resource appDefragAndOptimizeDrives 'Microsoft.DesktopVirtualization/applicationGroups/applications@2022-04-01-preview' = [for app in config: {
  name: '${app.name}'
  parent: appGroup
  properties: {
    applicationType: app.applicationType
    friendlyName: app.friendlyName
    description: app.description
    filePath: app.filePath
    iconPath: app.iconPath
    iconIndex: app.iconIndex
    commandLineSetting: app.commandLineSetting
    commandLineArguments: app.commandLineArguments
    showInPortal: true
  }
}]
