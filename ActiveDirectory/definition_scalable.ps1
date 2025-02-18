[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
    [Parameter()]
    [String]
    $Name,

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
    $TestBranch,

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [String]
    $DomainName = 'willywonka.dev',

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [ValidateSet('Small','Medium','Large')]
    $DomainControllerVMSize = 'Small',

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [ValidateSet('Small','Medium','Large')]
    $ClientVMSize = 'Small',

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [ValidateSet('Small','Medium','Large')]
    $ChocolateyServerVMSize = 'Large'
)

end {
    New-LabDefinition -Name ActiveDirectory -DefaultVirtualizationEngine HyperV

    Add-LabDomainDefinition -Name $DomainName -AdminUser Install -AdminPassword Somepass1
    Set-LabInstallationCredential -Username Install -Password Somepass1

    # Define the various resource allocations for VM Size
    $resources = @{
        Large = @{
            Memory = 16GB
            Processors = 4
        }
        Medium = @{
            Memory = 8GB
            Processors = 4
        }
        Small = @{
            Memory = 2GB
            Processors = 2
        }
    }

    #  Domain Controller
    $DC = @{
        Name            = 'DC01'
        OperatingSystem = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
        Memory          = $resources[$DomainControllerVMSize]['Memory']
        Processors      = $resources[$DomainControllerVMSize]['Processors']
        Roles           = 'RootDC'
        DomainName      = $DomainName
    }

    Add-LabMachineDefinition @DC

    # Client PC
    $client = @{
        Name            = 'ClientPC01'
        Memory          = $resources[$ClientVMSize]['Memory']
        Processors      = $resources[$ClientVMSize]['Processors']
        OperatingSystem = 'Windows 10 Pro'
        DomainName      = $DomainName
    }

    Add-LabMachineDefinition @client

    # Add Chocolatey Server if requested
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
                Memory                   = $resources[$ChocolateyServerVMSize]['Memory']
                Processors               = $resources[$ChocolateyServerVMSize]['Processors']
                PostInstallationActivity = $Role
                NetworkAdapter           = $nic1,$nic2
                DomainName = $DomainName
            }
    
            Add-LabMachineDefinition @configuration
        }
    }

    Install-Lab
}