#Get list of loaded module
Get-Module

#Get all versions of installed modules
Get-InstalledModule -Name Az.Kusto -AllVersions | Select Name, Version

#Install required azure commandlet using administrator previleges 
Install-Module -Name Az -AllowClobber -SkipPublisherCheck

#Import Module
Import-Module Az

#Connect Azure remotely with multi-factor authentiacation
Connect-AzAccount -TenantId cdf32132-1c15-4d10-9ea8-8b6009630dc6

#List subscription
Get-AzSubscription -SubscriptionName 'home_subscription'

#Select one specific subscription
Select-AzSubscription -SubscriptionId '46861af6-3496-44f0-8968-11ce30ae6294'

#Get the resource grous
Get-AzResourceGroup

#Delete Resource Group
Remove-AzResourceGroup -Name $resourceGroup

#Get AzContext
Get-AzContext

#Get Tenant ID 
Connect-AzAccount
Get-AzTenant

###Create a Virtual Network ###
#Check that the resource group exists, if not create it.
$rsgName = "pathomida-rg"
$loc = "Japan West"
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

#Create a secure string variable of your chosen secret.
[SecureString]$secretvalue = Read-Host -Prompt "Enter secret" -AsSecureString


#Set the secret in Key Vault by running this command
$secret = Set-AzKeyVaultSecret -VaultName "shuoh-contoso-keyvault" -Name "shuohTest" -SecretValue $secretvalue

#List all of the secrets in one key vault
Get-AzKeyVaultSecret -VaultName "shuoh-contoso-keyvault"

#Find and print out the secrete
$secret = Get-AzKeyVaultSecret -VaultName "shuoh-contoso-keyvault" -Name "shuohTest"
Write-Host "Secret Value is: " $secret.SecretValueText

#Create a certificate policy
$policy = New-AzKeyVaultCertificatePolicy -SubjectName "CN=shuohTest" -IssuerName Self -ValidityInMonths 12

#Create a certificate key valut using the police just created
Add-AzKeyVaultCertificate -VaultName "shuoh-contoso-keyvault" -Name "shuohTestCertificate" -CertificatePolicy $policy

#Check the status of the Certificate-creation
Get-AzKeyVaultCertificateOperation -VaultName "shuoh-contoso-keyvault" -Name "shuohTestCertificate" 

#Retrieve the public key (Thumber Pinrt) of the given certificate
Get-AzKeyVaultCertificate -VaultName "shuoh-contoso-keyvault" -Name "shuohTestCertificate"

###Create SQL Server ###
az sql server create --name "<alias>-westeurope-sql" --resource-group "<alias>-rg" --location "westeurope" --admin-user "demouser" --admin-password "demo@pass123"
$srvrName = "shuoh-westeurope-sql"
New-AzSqlServer -ResourceGroupName $rsgName -Location $loc -ServerName $srvrName -ServerVersion "12.0" -SqlAdministratorCredentials (Get-Credential)


#Configure the Azure SQL server firewall to allow Azure service and resources to access the server
New-AzSqlServerFirewallRule -ResourceGroupName $rsgName -ServerName $srvrName -FirewallRuleName "Allow Azure services" -StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0"

#Create a database on the Azure SQL server
New-AzSqlDatabase -ResourceGroupName $rsgName -ServerName $srvrName -DatabaseName "ContosoAds" -Edition "Basic"

#Create a new storage account
New-AzStorageAccount -ResourceGroupName $rsgName -Name shuohstorage -Location $loc -SkuName Standard_LRS -AccessTier "Hot" -Kind "StorageV2"

###Create Web Apps (PaaS) ###
#create the zip package of the given Web application
Compress-Archive -Path .\ContosoAds.Web\* -DestinationPath ContosoAds.Web.zip
#URL for the storage account used to put the zip package of the web app for following installation
#http://shuohchen-webapp.scm.azurewebsites.net/ZipDeployUI/ontosoAds.Web.zip

#Or Deploy Web App zip package via Cmdlet
az webapp deployment source config-zip --resource-group "<alias>-rg" --name "<alias>-webapp" --src "ContosoAds.Web.zip"
Publish-AzWebApp -ResourceGroupName $rsgName -Name "shuohchen-webapp" -ArchivePath "https://shuohchen-webapp.scm.azurewebsites.net/ZipDeployUI/"

###Solve the issue "The subscription is not registered to use namespace 'microsoft.insight" ###
#For PowerShell, use Get-AzResourceProvider to see your registration status
Get-AzResourceProvider -ListAvailable | Where-Object {($_.ProviderNamespace -like 'microsoft.insights')}

#To register a provider, use Register-AzResourceProvider and provide the name of the resource provider you wish to register
Register-AzResourceProvider -ProviderNamespace microsoft.insights

#Open the given file in its default editor
start .\RolloutSpec.json

#Browse to C:\Ev2PSClient in file explorer, and then double-click the AzureServiceDeployClient shortcut. This will open a PowerShell console and load the ExpressV2 module
#Initiate a new Azure Service Rollout:
New-AzureServiceRollout -ServiceGroupRoot "C:\Repos\EngSys\AzureBootcampContosoAds\ExpressV2\ServiceGroupRoot" -RolloutSpec "RolloutSpec.json" -RolloutInfra Prod -WaitToComplete

