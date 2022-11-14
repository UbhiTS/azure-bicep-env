# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# Install-Module -Name AzureAD
# Connect-AzureAD -TenantId 5798e0c9-74ff-4e3a-995e-a14a330c5616, this will hang the VSCode Terminal, press alt-tab for the login screen


$domainConfig = Get-Content './base/config/domain.json' | Out-String | ConvertFrom-Json

for ($i = 0; $i -lt $domainConfig.groups.Length; $i++) {

    $groupName = $domainConfig.groups[$i].name
    $userPrefix = $domainConfig.groups[$i].userPrefix

    $group = Get-AzureADGroup -Filter ("DisplayName eq '{0}'" -f $groupName)
    if ($group -eq $null) {
        $group = New-AzureADGroup -DisplayName $groupName -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        Write-Host $groupName
    }

    $domainConfig.groups[$i].objectId = $group.ObjectId

    for ($j = 0; $j -lt $domainConfig.numUsers; $j++) {
        
        $username = $userPrefix + $j
        $userPrincipleName = "{0}@{1}" -f $username, $domainConfig.domain

        $user = Get-AzureADUser -Filter ("UserPrincipalName eq '{0}'" -f $userPrincipleName)
        if ($user -eq $null) {
            $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
            $PasswordProfile.Password = $domainConfig.defaultPassword
            $user = New-AzureADUser -DisplayName $username -PasswordProfile $PasswordProfile -UserPrincipalName $userPrincipleName -AccountEnabled $true -MailNickName $username
            Write-Host ("    {0}" -f $username)
        }

        # this is to force a password sync between AADDS and AAD for users who existed prior to AADDS
        $passwordUpdate = ConvertTo-SecureString "CoolerBicep!1@2" -AsPlainText -Force
        Set-AzureADUserPassword -ObjectId $user.ObjectId -Password $passwordUpdate
        Write-Host ("      Password changed to <temporary>")

        $passwordUpdate = ConvertTo-SecureString $domainConfig.defaultPassword -AsPlainText -Force
        Set-AzureADUserPassword -ObjectId $user.ObjectId -Password $passwordUpdate
        Write-Host ("      Password changed back to {0}" -f $domainConfig.defaultPassword)

        $groupMember = Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object {$_.UserPrincipalName -eq $userPrincipleName}
        if ($groupMember -eq $null) {
            Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $user.ObjectId
            Write-Host ("        added to {0}" -f $groupName)
        }
    }

    Write-Host
}

$domainConfig | ConvertTo-Json -depth 99 | Out-File './base/config/domain.json'