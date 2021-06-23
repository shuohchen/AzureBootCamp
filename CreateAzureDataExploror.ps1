$rsgName = "shouhchen-rg"
$loc = "Central Us"
$ADXName ="shuohchenadx"
$kustoDBName = "shuohchendb"
#Import Module
Import-Module Az

#Connect Azure remotely with multi-factor authentiacation
Connect-AzAccount

#Select one specific subscription
Select-AzSubscription -SubscriptionId '7adeba7f-4949-4201-b9c2-59283fcb5e11'

#Install the Kusto modules to work with Azure Data Explorer
Install-Module -Name Az.Kusto -AllowClobber

#Create the Resource Group
New-AzResourceGroup -Name $rsgName -Location $loc

#Create the Azure Data Explorer cluster
New-AzKustoCluster -Name $ADXName -ResourceGroupName $rsgName -SkuName Standard_LRS -SkuTier Standard 

#Create Cluster database for data ingestion
New-AzKustoDatabase -Name $kustoDBName -ClusterName $ADXName -ResourceGroupName $rsgName -SoftDeletePeriod 30 -HotCachePeriod 7
