param baseConfig object
param domainConfig object

module vmLoginRolesAssignment './vm-login-roles-assignment.bicep' = [ for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'assign-vm-login-role-${group.userPrefix}-on-${baseConfig.rg.name}'
  scope: resourceGroup(baseConfig.rg.name)
  params: {
    adGroupId: group.objectId
    isAdmin: group.type == 'avdAdmin'
  }
}]

