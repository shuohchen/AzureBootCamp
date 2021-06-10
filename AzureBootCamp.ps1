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
Get-AzResourceGroup -Name shouhchen-rg -ErrorVariable notPresent -ErrorAction SilentlyContinue
if($notPresent)
{
 New-AzResourceGroup -Name shouhchen-rg -Location "Central Us"
}

#Create a variable for the subnet
$appsSubnet = New-AzVirtualNetworkSubnetConfig -Name apps -AddressPrefix "10.0.0.0/24"
$dataSubnet = New-AzVirtualNetworkSubnetConfig -Name data -AddressPrefix "10.0.1.0/24"

#Create Virtual Network
$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName shouhchen-rg -Location CentralUs -Name contosoads-vnet -AddressPrefix 10.0.0.0/16 -Subnet $appsSubnet,$dataSubnet

#You can check the virtual network address space by typing the below command
$virtualNetwork.AddressSpace
$virtualNetwork.Subnets

