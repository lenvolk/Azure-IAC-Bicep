
# Install AZ Cli
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# from AAD properties make sure "Access management for Azure resources" is set to yes

New-AzRoleAssignment -SignInName "lv@lvolk.com" -Scope "/" -RoleDefinitionName "Owner"

#Choose MAG
Connect-AzAccount -EnvironmentName AzureUSGovernment
# authenticate to the portal
Add-AzAccount
#Select the correct subscription
Get-AzSubscription -SubscriptionName "MSDN-SUB" | Select-AzSubscription

# to list the regions
# az account list-locations --query "sort_by([].{Location:name}, &Location)" -o table

cd C:\Bicep\Azure-IAC-Bicep\Standard-Deployments\CAF-Landing-Zone-MG\
dir
New-AzTenantDeployment -TemplateFile .\caf-mg-deploy.bicep -TemplateParameterFile .\volk_parameters.json -Location eastus2


### Clean-UP
$rgfilter = 'my-caf-vnet'
$rg2delete = Get-AzResourceGroup | ? ResourceGroupName -match $rgfilter | Select-Object ResourceGroupName
$rg2delete | Remove-AzResourceGroup -AsJob -Force

# to remove subscription from managment group
Remove-AzManagementGroupSubscription -GroupId 'volk-connectivity' -SubscriptionId '77950549-89f8-47fa-bf94-49cba3c855f0'


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

remove-recursively -name 'volk-sandbox'

disconnect-azaccount 
