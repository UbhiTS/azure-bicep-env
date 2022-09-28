//param sessionHostName string

resource sessionHostForStorageAccountNTFSPermissions 'Microsoft.Compute/virtualMachines@2022-03-01' existing = {
  name: 'dev-host-vm-0'
}

resource mountSA 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'mount-sa'
  location: resourceGroup().location
  parent: sessionHostForStorageAccountNTFSPermissions
  properties: {
    source: {
      commandId: 'RunPowerShellScript'
      scriptUri: 'C:\\run.ps1'
    }
    runAsUser: '.\\vmadmin'
    runAsPassword: 'CoolBicep!1@2'
  }
}
