$subscriptionName = "Azure Boot Camp (Alpha)"
$vaultName = "ContosoAdsKeyVault"
$certName = "ABCLab"

Add-Type -AssemblyName System.Web
$password = [System.Web.Security.Membership]::GeneratePassword(16, 3)

$pfxPath = "$env:userprofile\$certName.pfx"

Connect-AzAccount -DeviceCode
Set-AzContext -SubscriptionName $subscriptionName

$cert = Get-AzKeyVaultSecret -VaultName $vaultName -Name $certName
$certBytes = [System.Convert]::FromBase64String($cert.SecretValueText)
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certCollection.Import($certBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
$protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $password)
[System.IO.File]::WriteAllBytes($pfxPath, $protectedCertificateBytes)

$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
Import-PfxCertificate -FilePath $pfxPath Cert:\CurrentUser\My -Password $securePassword

Remove-Item $pfxPath