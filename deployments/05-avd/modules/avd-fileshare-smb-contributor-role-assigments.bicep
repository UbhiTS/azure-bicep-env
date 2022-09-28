param fileShareName string
param groupObjectId string

var roleDefinitionId = '/providers/Microsoft.Authorization/roleDefinitions/0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb' // storage file data smb share contributor

resource fs 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' existing = {
  name: fileShareName
}

resource appGroupRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, fileShareName, groupObjectId)
  scope: fs
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: groupObjectId
    principalType: 'Group'
  }
}
