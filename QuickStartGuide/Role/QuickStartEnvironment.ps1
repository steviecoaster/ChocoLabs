Param(
    [Parameter()]
    [String]
    $CertPass,

    [Parameter()]
    [String]
    $CertificateDnsName,

    [Parameter()]
    [pscredential]
    $DatabaseCredential
)

$helpers = Join-Path $PSScriptRoot -ChildPath 'helpers.ps1'

. $helpers

#Collect the files we need
$cert = Join-Path $PSscriptRoot -ChildPath 'cert.pfx'
$license = Join-Path $PSscriptRoot -ChildPath 'chocolatey.license.xml'

#Get the cert details
$certData = Get-PfxCertificate -FilePath $cert -Password ($CertPass | ConvertTo-SecureString -AsPlainText -Force)
#Import the certificate to the VM
Import-PfxCertificate -FilePath $cert -CertStoreLocation Cert:\LocalMachine\My -Exportable -Password ($CertPass | ConvertTo-SecureString -AsPlainText -Force)
Import-PfxCertificate -FilePath $cert -CertStoreLocation Cert:\LocalMachine\TrustedPeople -Exportable -Password ($CertPass | ConvertTo-SecureString -AsPlainText -Force)

#Peel Thumbprint off the cert
$thumbprint = (Get-ChildItem Cert:\LocalMachine\my).Thumbprint

#Add an entry to the hosts file so we don't have to rely on working DNS for setup
New-HostsFileEntry -IpAddress '127.0.0.1' -Hostname $CertificateDnsName

#Set Exeuction Policy and TLS 1.2 (Probably don't need this, but won't hurt to no-op)
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::tls12

#This is Step 0 of the Quick Start Guide
$params = @{
    LicenseFile = $license
}

$script = Invoke-RestMethod https://ch0.co/qsg-go
& ([scriptblock]::Create($script)) @params

Push-Location "$env:SystemDrive\choco-setup\files"
$SkipBrowserLaunch = $true #Hack to keep web browsers opening up on us in the lab
.\Start-C4bNexusSetup.ps1
.\Start-C4bCcmSetup.ps1 -DatabaseCredential $DatabaseCredential
.\Start-C4bJenkinsSetup.ps1
.\Set-SslSecurity.ps1 -Thumbprint $thumbprint -CertificateDnsName $CertificateDnsName -Hardened
Pop-Location