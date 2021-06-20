$vaultName = "shuoh-sf-keyvault"
$certName = "shuoh-sf-certificate"
#$certName = "shuohchen-sf-certificate"
$subscriptionName = "Visual Studio Enterprise Subscription"

# Parameters for export of cert
$password = "05150325Chen"
$pfxPath = "$env:USERPROFILE\certexport.pfx"

# Login to Azure
Connect-AzAccount

# Make sure we're running commands against the correct subscription
Select-AzSubscription -SubscriptionName $subscriptionName

# Get the bytes of the certificate from KeyVault
#[Origin Code, but not work 20210620] $cert = Get-AzKeyVaultSecret -VaultName $vaultName -Name $certName
$cert =Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certName
$certBytes = [System.Convert]::FromBase64String($cert.Thumbprint)

#$certBytes = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($cert.Thumbprint))
#$jsonCert = ConvertFrom-Json($certBytes)
#$certBytes = [System.Convert]::FromBase64String($jsonCert.data)

# Setup a new cert collection in memory and load in the bytes as a proper cert that can be exported
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certCollection.Import($certBytes,$password,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

#$certCollection.Import($certBytes,$jsonCert.password,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
# Prepare to export the cert collection protected by a password
$secure = ConvertTo-SecureString -String $password -AsPlainText -Force
$protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $password)

# Write the protected cert to disk
[System.IO.File]::WriteAllBytes($pfxPath, $protectedCertificateBytes)

# Import that cert to the Current User\My certificate store for use in authenticating with SF
Import-PfxCertificate -FilePath "$pfxPath" Cert:\CurrentUser\My -Password $secure



$kvSecret = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certName
$kvSecretBytes = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($kvSecret.SecretValueText))
$jsonCert = ConvertFrom-Json($kvSecretBytes)
$certBytes = [System.Convert]::FromBase64String($jsonCert.data)
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certCollection.Import($certBytes,$jsonCert.password,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)