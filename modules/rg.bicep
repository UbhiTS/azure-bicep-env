targetScope = 'subscription'

param config object

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: config.rg.name
  location: config.rg.location
}

output id string = rg.id
output name string = rg.name
output location string = rg.location
