###Ref: https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-powershell
###You can assign a role to a user, group, service principal, or managed identity

##Connect Azure Portal
#Import Module
Import-Module Az

#Connect Azure remotely with multi-factor authentiacation
Connect-AzAccount -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

#Select one specific subscription, CSI HHS DEV Sub
Select-AzSubscription -SubscriptionId 'b2370992-8afd-4ee4-ba1d-b4c6ea6298af'

##1st step: Get the unique ID of the object
#Service Principle
(Get-AzADApplication -ObjectId  dea6735d-a13c-40f2-926d-e4d2d2bef631 | Get-AzADServicePrincipal).id

## 2nd step: Select the appropriate role
Get-AzRoleDefinition | Where-Object {($_.Name -like 'Contributor')}

## 3rd step : Identify the needed scope
Get-AzResourceGroup
#resource scope 
# You can find the resource ID by looking at the properties of the resource in the Azure portal. A resource ID has the following format.
#/subscriptions/<subscriptionId>/resourcegroups/<resourceGroupName>/providers/<providerName>/<resourceType>/<resourceSubType>/<resourceName>
#/subscriptions/b2370992-8afd-4ee4-ba1d-b4c6ea6298af/resourcegroups/neochen-rg2/providers/Microsoft.Kusto/Clusters/kustofunctestcluster3

# 4th step: Assign role
New-AzRoleAssignment -ObjectId f5d3a79a-afee-4d96-ac5b-9389163b39e5 `
-RoleDefinitionName "Contributor" `
-Scope "/subscriptions/b2370992-8afd-4ee4-ba1d-b4c6ea6298af/resourcegroups/neochen-rg2/providers/Microsoft.Kusto/Clusters/kustofunctestcluster3"