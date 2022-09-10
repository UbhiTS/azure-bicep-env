# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# az account set --subscription "Azure Sponsored UbhiMS"
# az account set --subscription "Visual Studio Enterprise Subscription"

# -f Microsoft.Compute/virtualMachineScaleSets

$primarySecuredAADDSConfig = Get-Content ..\deployments\aadds\config\primary.json -Raw | ConvertFrom-Json

az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $primarySecuredAADDSConfig.rg.name -y

$primarySecuredFWConfig = Get-Content ..\deployments\hub-firewall-spokes-vms\config\primary.json -Raw | ConvertFrom-Json
$secondarySecuredFWConfig = Get-Content ..\deployments\hub-firewall-spokes-vms\config\secondary.json -Raw | ConvertFrom-Json
$tertiarySecuredFWConfig = Get-Content ..\deployments\hub-firewall-spokes-vms\config\tertiary.json -Raw | ConvertFrom-Json

az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $primarySecuredFWConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $secondarySecuredFWConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $tertiarySecuredFWConfig.rg.name -y

$primaryBaseConfig = Get-Content .\config\primary.json -Raw | ConvertFrom-Json
$secondaryBaseConfig = Get-Content .\config\secondary.json -Raw | ConvertFrom-Json
$tertiaryBaseConfig = Get-Content .\config\tertiary.json -Raw | ConvertFrom-Json

az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $primaryBaseConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $secondaryBaseConfig.rg.name -y
az group delete --no-wait -f Microsoft.Compute/virtualMachines -n $tertiaryBaseConfig.rg.name -y

az group list -o table
