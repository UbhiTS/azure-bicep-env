// var domainConfig = loadJsonContent('../../../base/config/domain.json')
// var config = loadJsonContent('../../../base/config/avd.json')

param domainConfig object
param config object

// create storage account

resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name : config.storage.accountName
  location : config.rg.location
  kind : 'FileStorage'
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: 'AADDS'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    supportsHttpsTrafficOnly: true
  }
}

// create fileshare

resource fs 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name :  '${sa.name}/default/${config.storage.fileShareFolderName}'
  properties: {
    accessTier: 'Premium' // since it's a FileStorage account, we need to use premium only
    enabledProtocols: 'SMB'
    shareQuota: 100
  }
}

// + ================================================================================================

// BUG: the below workaround to assign RBAC permissions to the fileshare are due to a bug in bicep
// https://github.com/Azure/bicep/issues/6100 - Role Assignment on Storage Account File share

resource ResourceRoleAssignmentUsers 'Microsoft.Resources/deployments@2021-04-01' = [for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
  name: 'user-permissions_${group.userPrefix}'
  properties: {
    mode: 'Incremental'
    expressionEvaluationOptions: {
      scope: 'Outer'
    }
    template: json(loadTextContent('./arm-role-assignment-workaround.json'))
    parameters: {
      scope: {
        value: replace(fs.id, '/shares/','/fileshares/')
      }
      name: {
        value: guid('${subscription().id},${resourceGroup().id},${sa.name},${fs.name},${group.userPrefix}')
      }
      roleDefinitionId: {
        value: '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb' // Storage File Data SMB Share Contributor
      }
      principalId: {
        value: group.objectId
      }
      principalType: {
        value: 'Group'
      }
    }
  }
}]

// module fsRoleAssignments './avd-fileshare-smb-contributor-role-assigments.bicep' = [for group in domainConfig.groups: if (group.type == 'avdAdmin' || group.type == 'user') {
//   name: 'deploy-fileshare-${group.userPrefix}-role-assignments'
//   params: {
//     fileShareName: fs.name
//     groupObjectId: group.objectId
//   }
// }]

// - ================================================================================================
