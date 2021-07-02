# Azure Survice Deploy Powershell
#-RolloutInfra : Prod | Test | Dev |Mooncake | Fairfax | BlackForest | USNat | USSec
New-AzureServiceRollout -ServiceGroupRoot "C:\Repos\EngSys\AzureBootcampContosoAds\ExpressV2\ServiceGroupRoot" -RolloutSpec "RolloutSpec.json" -RolloutInfra Prod -WaitToComplete