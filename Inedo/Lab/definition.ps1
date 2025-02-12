[CmdletBinding()]
Param(
    [Parameter()]
    [String]
    $Name,

    [Parameter()]
    [PSCredential]
    $ServerLogin,

    [Parameter()]
    [String]
    $CertificateDnsName
)
# Define our Lab definition
New-LabDefinition -Name $Name -DefaultVirtualizationEngine HyperV
    
# Define a role for our server
$role = Get-LabPostInstallationActivity -CustomRole Inedo -Properties @{CertificateDnsName = $CertificateDnsName}
# Configure the network for our server
Add-LabVirtualNetworkDefinition -Name 'Default Switch'
$nic1 = New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp
    
# Set the Lab VM credential
Set-LabInstallationCredential -Username $ServerLogin.UserName -Password $ServerLogin.GetNetworkCredential().Password
    
# Define the server itself in the Lab
$cofiguration = @{
    Name                     = 'ProGetServer'
    OperatingSystem          = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
    Memory                   = 16GB
    Processors               = 4
    NetworkAdapter           = $nic1
    PostInstallationActivity = $role
}

Add-LabMachineDefinition @cofiguration

Install-Lab