[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
    [Parameter(ParameterSetName = 'QSG', Mandatory)]
    [Switch]
    $IncludeChocolateyServer,

    [Parameter(ParameterSetName = 'QSG')]
    [PSCredential]
    $Credential,

    [Parameter(ParameterSetName = 'QSG')]
    [PSCredential]
    $DatabaseCredential,
    
    [Parameter(ParameterSetName = 'QSG')]
    [String]
    $CertificateDnsName,

    [Parameter(ParameterSetName = 'QSG')]
    [String]
    $TestBranch
)

end {
    New-LabDefinition -Name ActiveDirectory -DefaultVirtualizationEngine HyperV

    Add-LabDomainDefinition -Name steviecoaster.dev -AdminUser Install -AdminPassword Somepass1
    Set-LabInstallationCredential -Username Install -Password Somepass1


    $DC = @{
        Name            = 'DC01'
        OperatingSystem = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
        Memory          = 8GB
        Processors      = 2
        Roles           = 'RootDC'
        DomainName      = 'steviecoaster.dev'
    }

    Add-LabMachineDefinition @DC

    $client = @{
        Name            = 'ClientPC01'
        Memory          = 8GB
        OperatingSystem = 'Windows 10 Pro'
        DomainName      = 'steviecoaster.dev'
    }

    Add-LabMachineDefinition @client

    switch ($PSCmdlet.ParameterSetName) {

        'QSG' {
            $properties = @{
                CertPass           = 'poshacme'
                CertificateDnsName = $CertificateDnsName
                DatabaseCredential = $DatabaseCredential
            }

            #If testing a PR, supply the PR Id number. Environment will be built from PR branch
            if ($TestBranch) {
                $properties.Add('TestBranch', $TestBranch)
            }

            Set-LabInstallationCredential -Username $credential.Username -Password $credential.GetNetworkCredential().Password
            Add-LabVirtualNetworkDefinition -Name 'Default Switch' -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }
            $nic1 = New-LabNetworkAdapterDefinition -UseDhcp -VirtualSwitch 'Default Switch'
            $nic2 = New-LabNetworkAdapterDefinition -VirtualSwitch 'ActiveDirectory' -Ipv4Address '192.168.11.150' -Ipv4Gateway '0.0.0.0' -Ipv4DNSServers '192.168.11.3'

            #Define a role for our server
            $role = Get-LabPostInstallationActivity -CustomRole QuickStartEnvironment -Properties $properties
            #Define the server itself in the Lab
            $configuration = @{
                Name                     = 'ChocoServer'
                OperatingSystem          = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
                Memory                   = 16GB
                Processors               = 4
                PostInstallationActivity = $Role
                NetworkAdapter           = $nic1,$nic2
                DomainName = 'steviecoaster.dev'
            }
    
            Add-LabMachineDefinition @configuration
        }
    }

    Install-Lab
    Show-LabDeploymentSummary -Detailed

}