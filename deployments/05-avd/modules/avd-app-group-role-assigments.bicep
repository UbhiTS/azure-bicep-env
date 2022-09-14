param appGroupName string
param assignToGroups array
param domainConfig object


var adGroupNames = [ for i in range(0, length(domainConfig.groups)): domainConfig.groups[i].name ]
var adGroupObjectIds = [ for i in range(0, length(domainConfig.groups)): domainConfig.groups[i].objectId ]

var roleDefinitionId = '/providers/Microsoft.Authorization/roleDefinitions/1d18fff3-a72a-46b5-b4a9-0b38a3cd7e63' // Desktop Virtualization User

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' existing = {
  name: appGroupName
}

resource appGroupRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [ for assignToGroup in assignToGroups: {
  name: guid(subscription().id, resourceGroup().id, appGroupName, assignToGroup)
  scope: appGroup
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: adGroupObjectIds[indexOf(adGroupNames, assignToGroup)]
    principalType: 'Group'
  }
}]
