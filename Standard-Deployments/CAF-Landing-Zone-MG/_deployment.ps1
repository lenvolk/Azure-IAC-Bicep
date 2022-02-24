New-AzRoleAssignment -SignInName "lv@volk.com" -Scope "/" -RoleDefinitionName "Owner"

# authenticate to the portal
Add-AzAccount
#Select the correct subscription
Get-AzSubscription -SubscriptionName "MSDN-SUB" | Select-AzSubscription

# For Azure global regions
New-AzTenantDeployment -TemplateFile .\caf-mg-deploy.bicep -TemplateParameterFile .\parameters.json -Location eastus2


### Clean-UP
Remove-AzManagementGroupSubscription -GroupId 'alz' -SubscriptionId 'c6aa1fdc-66a8-446e-8b37-7794cd545e44'


function remove-recursively($name) {
  #Enters the parent Level
  Write-Host "Entering the scope with $name" -ForegroundColor Green
  $parent = Get-AzManagementGroup -GroupName $name -Expand -Recurse

  #Checks if there is any parent level.
  if ($parent.Children -ne $null) {
    Write-Host "Found the following Children :" -ForegroundColor White
    Write-host ($parent.Children | select Name).Name -ForegroundColor Yellow
    foreach ($children in $parent.Children) {
      #tries to recurs to each child item
      remove-recursively($children.Name)
    }
  }

  #this below executes if all the child items are deleted or if doesn't have any child item
  Write-Host "Removing the scope $name" -ForegroundColor Cyan
  #Comment the below line if you just want to understand the flow
  Remove-AzManagementGroup -InputObject $parent
}

remove-recursively -name 'alz'

disconnect-azaccount 
