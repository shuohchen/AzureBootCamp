#Get list of loaded module
Get-Module

#Install required azure commandlet using administrator previleges 
Install-Module -Name Az -AllowClobber -SkipPublisherCheck

#Import Module
Import-Module Az

#Connect Azure remotely with multi-factor authentiacation
Connect-AzAccount -TenantId cdf32132-1c15-4d10-9ea8-8b6009630dc6

#List subscription
Get-AzSubscription -SubscriptionName 'Visual Studio Enterprise Subscription'

#Select one specific subscription
Select-AzSubscription -SubscriptionId '0ea55d77-1224-4a86-a888-913c1ed0fb83'

#Get the resource grous
 Get-AzResourceGroup

#Get AzContext
Get-AzContext

###Create a Virtual Network ###
#Check that the resource group exists, if not create it.
$rsgName = "shouhchen-rg"
$loc = "Central Us"
Get-AzResourceGroup -Name $rsgName -ErrorVariable notPresent -ErrorAction SilentlyContinue
if($notPresent)
{
 New-AzResourceGroup -Name $rsgName -Location $loc
}

#Create a variable for the subnet
$appsSubnet = New-AzVirtualNetworkSubnetConfig -Name apps -AddressPrefix "10.0.0.0/24"
$dataSubnet = New-AzVirtualNetworkSubnetConfig -Name data -AddressPrefix "10.0.1.0/24"

#Create Virtual Network
$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName $rsgName -Location $loc -Name contosoads-vnet -AddressPrefix 10.0.0.0/16 -Subnet $appsSubnet,$dataSubnet

#You can check the virtual network address space by typing the below command
$virtualNetwork.AddressSpace
$virtualNetwork.Subnets

###Create virtual machine ###
##SQL Server VM##
# Deploy to a resource group with ARM template with inline parameters 
$arrayParam = @{ "alias" = "neochen"; "adminPassword" = "demo@pass123"}
New-AzResourceGroupDeployment -ResourceGroupName $rsgName -TemplateFile azuredeploy.sql.json -TemplateParameterObject  $arrayParam

##Web Server VM##

#Create a storage account, Standard_LRS :Locally-redundant storage
New-AzStorageAccount -ResourceGroupName $rsgName -Name shouhchendsc -Location $loc -SkuName Standard_LRS
$storageAccount = Get-AzStorageAccount | Select-Object -Last 1

#Create a container for blob files
$containerName = "dsc"
New-AzStorageContainer -Name $containerName -Context $storageAccount.Context -Permission blob

#upload a blob
#az storage blob upload --account-name "<alias>dsc" -c dsc -f web-dsc-config.zip -n web-dsc-config.zip
Set-AzStorageBlobContent -File "web-dsc-config.zip" -Container $containerName -Blob "web-dsc-config.zip" -Context $storageAccount.Context 

#Retrieve SAS Token
$context = New-AzStorageContext -StorageAccountName $account_name -StorageAccountKey $account_key

#you can also add other parameter as per your need, like StartTime, ExpiryTime etc.
$SASToken = New-AzStorageAccountSASToken -Service Blob -ResourceType Service,Container,Object -Permission rw -Context $storageAccount.Context -ExpiryTime "2030-01-01"

#Deploy an Azure Resource Manager Template
$arrayParam = @{ "alias" = "neochen"; "adminPassword" = "demo@pass123" ; "dscModulesUrl"= "https://shouhchendsc.blob.core.windows.net/dsc/web-dsc-config.zip"+$SASToken}
New-AzResourceGroupDeployment -ResourceGroupName $rsgName -TemplateFile azuredeploy.web.json -TemplateParameterObject  $arrayParam


### Create a key-vault resource ###
New-AzKeyVault -VaultName "shuoh-contoso-keyvault" -ResourceGroupName $rsgName -Location $loc -EnabledForDeployment

