param baseConfigPrimary object
param baseConfigSecondary object
param baseConfigTertiary object

param domainConfig object

module vmLoginRolesAssignmentPrimary './vm-login-roles-assignment.bicep' = [ for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'assign-vm-login-role-${group.userPrefix}-on-${baseConfigPrimary.rg.name}'
  scope: resourceGroup(baseConfigPrimary.rg.name)
  params: {
    adGroupId: group.objectId
    isAdmin: group.type == 'avdAdmin'
  }
}]

module vmLoginRolesAssignmentSecondary './vm-login-roles-assignment.bicep' = [ for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'assign-vm-login-role-${group.userPrefix}-on-${baseConfigSecondary.rg.name}'
  scope: resourceGroup(baseConfigSecondary.rg.name)
  params: {
    adGroupId: group.objectId
    isAdmin: group.type == 'avdAdmin'
  }
}]

module vmLoginRolesAssignmentTertiary './vm-login-roles-assignment.bicep' = [ for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'assign-vm-login-role-${group.userPrefix}-on-${baseConfigTertiary.rg.name}'
  scope: resourceGroup(baseConfigTertiary.rg.name)
  params: {
    adGroupId: group.objectId
    isAdmin: group.type == 'avdAdmin'
  }
}]
