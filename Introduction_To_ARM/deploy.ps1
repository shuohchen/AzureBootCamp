param(
 [Parameter(Mandatory=$True)]
 [string]
 $resourceGroupName,

 [Parameter(Mandatory=$True)]
 [string]
 $webAppDnsName,

 [string]
 $location = "West Europe",
  
 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionName,

 [Parameter(Mandatory=$True)]
 [string]
 $sqlserverAdminPass,

 [string]
 $templateFilePath = "template.json",

 [string]
 $alias = $env:USERNAME.ToLower()
)

$ErrorActionPreference = "Stop"

$context = Get-AzContext -ErrorAction SilentlyContinue
if(!$context.Tenant){
    # sign in
    Write-Host "Logging in...";
    Connect-AzAccount;
}

$context = Get-AzContext
if(-not ($context.Subscription.Name -eq $subscriptionName)) {
    # select subscription
    Write-Host "Selecting subscription '$subscriptionName'";
    Select-AzSubscription -SubscriptionName $subscriptionName;
}

$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
     if(!$location) {
         Write-Host "To create a new resource group, please enter a location.";
         $location = Read-Host "location";
     }

     Write-Host "Creating resource group '$resourceGroupName' in location '$location'";
     New-AzResourceGroup -Name $resourceGroupName -Location $location
}

Write-Host "Starting deployment...";
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -alias $alias -location $location -webAppDnsName $webAppDnsName -sqlserverAdminPass $sqlserverAdminPass;