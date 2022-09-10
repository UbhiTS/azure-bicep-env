param adGroupId string
param isAdmin bool = false

var roles = {
  'Virtual Machine Administrator Login': '/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4'
  'Virtual Machine User Login': '/providers/Microsoft.Authorization/roleDefinitions/fb879df8-f326-4884-b1cf-06f3ad86be52'
}

var roleDefinitionId = isAdmin ? roles['Virtual Machine Administrator Login'] : roles['Virtual Machine User Login']

resource adminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, adGroupId, roleDefinitionId) // contraint: name can only be a unique guid
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: adGroupId
    principalType: 'Group'
  }
}

