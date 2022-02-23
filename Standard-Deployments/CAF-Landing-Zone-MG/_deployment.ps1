New-AzRoleAssignment -SignInName "lv@volk.com" -Scope "/" -RoleDefinitionName "Owner"

Add-AzAccount
#Select the correct subscription
Get-AzSubscription -SubscriptionName "MSDN-SUB" | Select-AzSubscription

# For Azure global regions
az deployment tenant create --template-file .\caf-mg-deploy.bicep --name mg-test -l eastus --parameters .\parameters.json