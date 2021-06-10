#Import the Azure PowerShell Module
Import-Module -Name Az

#Show Powershell version
#$PSVersionTable.PSVersion

#get help about certain commandlet
#Get-Help Get-ChildItem -detailed

#Search object
#Get-AzVMImagePublisher -Location $loc | Where-Object -Property PublisherName -Contains 'zscaler'
Get-AzVMImagePublisher -Location $loc | Where-Object {($_.PublisherName -like 'Canonical')}

# After finding the publisher, get their offers
Get-AzVMImageOffer -Location $loc -PublisherName "Canonical"

# Search for SKUs with the publisher and offer
Get-AzVMImageSku -Location $loc -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-focal"

# NOW you can search for your image
Get-AzVMImage -Location $loc -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-focal" -Skus "20_04-lts" | Select-Object -Last 1

#Connect to an Azure account 
Connect-AzAccount

#List Azure subscriptions
#Get-AzSubscription

#Define Azure variable for a virtual machine
$subscription = "46861af6-3496-44f0-8968-11ce30ae6294"
$VMName = "testvmJapest20210607"
$OSDiskName = "os-disk"
$DataDiskName = "data-disk"
$resourceGroup = "my-test-gp"
$loc = "japanwest"
$VMSize = Get-AzVMSize -Location $loc | Where-Object Name -eq "Standard_B1s" #only free vm for the free account

# List Available options for Size parameters 
#Get-AzVMSize  -Location $loc

#Select the right subscription 
Select-AzSubscription -SubscriptionId $subscription

#Create AZ VM config instance
$VMSettings = New-AzVMConfig -VMName $VMName -VMSize $VMSize.Name 

# Set the size of the OS disk.
# Also set that the OS disk is going to be created from an image
Set-AzVMOSDisk -VM $VMSettings -Name $OSDiskName -Linux -DiskSizeInGB 80 -CreateOption FromImage

# Add a data disk
Add-AzVMDataDisk -VM $VMSettings -Name $DataDiskName -DiskSizeInGB 100 -CreateOption Empty -Lun 1

# Get publishers of image you are looking for
Get-AzVMImagePublisher -Location $loc  | Select-Object -First 10

# Get VM images
Get-AzVMImage -Location $loc

#Create Azure Credentials
#$adminCredential= Get-Credential -Message "Enter a username and password for the VM Administrator"

New-AzVm -ResourceGroupName $resourceGroup -Name $vmName  -Credential (Get-Credential) -Location $loc -Image UbuntuLTS -OpenPorts 22

#Get VM information
$vm = (Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup)

#Get the property information of vm object
$vm.HardwareProfile

#Get the storage information
$vm.StorageProfile.OsDisk

#Get IP Address of my vm
$vm | Get-AzPublicIpAddress