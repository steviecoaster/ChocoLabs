[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [PSCredential]
    $Credential,

    [Parameter()]
    [PSCredential]
    $DatabaseCredential = (Get-Credential -Message 'Provide a password for the chocouser local SQL account to be created.' -UserName chocouser),
    
    [Parameter()]
    [String]
    $Hostname
)

end {

    #Define our Lab definition
    New-LabDefinition -Name QuickStartEnvironmentLab -DefaultVirtualizationEngine HyperV
    
    #Define a role for our server
    $role = Get-LabPostInstallationActivity -CustomRole QuickStartEnvironment -Properties @{
        CertPass = 'poshacme'
        CertificateDnsName = $hostname
        DatabaseCredential = $DatabaseCredential
    }

    #Configure the network for our server
    Add-LabVirtualNetworkDefinition -Name 'Default Switch'
    $nic1 = New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp
    
    #Set the Lab VM credential
    Set-LabInstallationCredential -Username $credential.Username -Password $credential.GetNetworkCredential().Password
    
    #Define the server itself in the Lab
    $cofiguration = @{
        Name            = 'ChocoServer'
        OperatingSystem = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
        Memory          = 16GB
        Processors      = 4
        NetworkAdapter         = $nic1
        PostInstallationActivity = $Role
    }

    Add-LabMachineDefinition @cofiguration

    Install-Lab
}