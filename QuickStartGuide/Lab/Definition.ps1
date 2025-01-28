[CmdletBinding()]
Param(
    [Parameter()]
    [String]
    $Name,

    [Parameter()]
    [PSCredential]
    $Credential = (Get-Credential -Message 'Provide a password for the local admin user to be created' -UserName sweettooth),

    [Parameter()]
    [PSCredential]
    $DatabaseCredential = (Get-Credential -Message 'Provide a password for the chocouser local SQL account to be created.' -UserName chocouser),
    
    [Parameter()]
    [String]
    $CertificateDnsName,

    [Parameter()]
    [String]
    $TestBranch
)

end {

    #Define our Lab definition
    New-LabDefinition -Name $Name -DefaultVirtualizationEngine HyperV
    
    #Define base properties to pass to the custom role for installation
    $properties = @{
        CertPass = 'poshacme'
        CertificateDnsName = $CertificateDnsName
        DatabaseCredential = $DatabaseCredential
    }

    #If testing a PR, supply the PR Id number. Environment will be built from PR branch
    if($TestBranch){
        $properties.Add('TestBranch',$TestBranch)
    }

    #Define a role for our server
    $role = Get-LabPostInstallationActivity -CustomRole QuickStartEnvironment -Properties $properties
    $clientRole = Get-LabPostInstallationActivity -CustomRole QuickStartClient -Properties @{Fqdn = $CertificateDnsName}

   

    #Configure the network for our server
    Add-LabVirtualNetworkDefinition -Name 'Default Switch'
    $nic1 = New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp
    $nic2 = New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp
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

    #Define the server itself in the Lab
    $cofiguration = @{
        Name            = 'ClientMachine'
        OperatingSystem = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
        Memory          = 8GB
        Processors      =  2
        NetworkAdapter         = $nic2
        PostInstallationActivity = $clientRole
    }

    Add-LabMachineDefinition @cofiguration

    Install-Lab
}