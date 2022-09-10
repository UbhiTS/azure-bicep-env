//var config = loadJsonContent('../config/primary.json')

param config object

// create storage account

resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name : config.storage.accountName
  location : config.rg.location
  kind : config.storage.kind
  sku: {
    name: config.storage.redundancy
  }
}

// create fileshare

resource fs 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name :  '${sa.name}/default/${config.storage.fileShareFolderName}'
}
