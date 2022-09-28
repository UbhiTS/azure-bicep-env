# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# az account set --subscription "Azure Sponsored UbhiMS"
# az account set --subscription "Visual Studio Enterprise Subscription"

# -f Microsoft.Compute/virtualMachineScaleSets

$primarySecuredAADDSConfig = Get-Content .\config\aadds.json -Raw | ConvertFrom-Json

az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $primarySecuredAADDSConfig.rg.name -y

$primarySecuredFWConfig = Get-Content ..\deployments\04-hub-firewall-spokes-vms\config\primary.json -Raw | ConvertFrom-Json
$secondarySecuredFWConfig = Get-Content ..\deployments\04-hub-firewall-spokes-vms\config\secondary.json -Raw | ConvertFrom-Json
$tertiarySecuredFWConfig = Get-Content ..\deployments\04-hub-firewall-spokes-vms\config\tertiary.json -Raw | ConvertFrom-Json

az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $primarySecuredFWConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $secondarySecuredFWConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $tertiarySecuredFWConfig.rg.name -y

$primaryBaseConfig = Get-Content .\config\base-primary.json -Raw | ConvertFrom-Json
$secondaryBaseConfig = Get-Content .\config\base-secondary.json -Raw | ConvertFrom-Json
$tertiaryBaseConfig = Get-Content .\config\base-tertiary.json -Raw | ConvertFrom-Json

az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $primaryBaseConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $secondaryBaseConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $tertiaryBaseConfig.rg.name -y

az group list -o table
