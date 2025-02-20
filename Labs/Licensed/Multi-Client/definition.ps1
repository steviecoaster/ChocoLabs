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
    $ServerLogin,

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
    [ValidateSet('Small', 'Medium', 'Large')]
    $DomainControllerVMSize = 'Small',

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [ValidateSet('Small', 'Medium', 'Large')]
    $ClientVMSize = 'Small',

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [Int]
    $ClientMachineCount,

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [String]
    $ClientOS,

    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'QSG')]
    [ValidateSet('Small', 'Medium', 'Large')]
    $ChocolateyServerVMSize = 'Large'
)

begin {
    
    function New-OptionSet {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory)]
            [String[]]
            $Options
        )
        end {
            $x = 1 
            foreach ($o in $Options) {
                '{0}. {1}' -f $x, $o
                $x++
            }
        }
    }

    function New-ClientPC {
        [CmdletBinding()]
        Param(
            [Parameter()]
            [String]
            $OperatingSystem,

            [Parameter()]
            [String]
            $ResourceSize,

            [Parameter()]
            [Int]
            $Count
        )

        end {
            $client = @{
                Name            = "ClientPC$($Count)"
                Memory          = $resources[$ResourceSize]['Memory']
                Processors      = $resources[$ResourceSize]['Processors']
                OperatingSystem = $OperatingSystem
                DomainName      = $DomainName
            }
            
            Add-LabMachineDefinition @client
        }
    }

    $AvailableOperatingSystems = (Get-LabAvailableOperatingSystem).OperatingSystemName
}

end {
    New-LabDefinition -Name $Name -DefaultVirtualizationEngine HyperV

    Add-LabDomainDefinition -Name $DomainName -AdminUser Install -AdminPassword Somepass1
    Set-LabInstallationCredential -Username $ServerLogin.Username -Password $ServerLogin.GetNetworkCredential().Password

    # Define the various resource allocations for VM Size
    $resources = @{
        Large  = @{
            Memory     = 16GB
            Processors = 4
        }
        Medium = @{
            Memory     = 8GB
            Processors = 4
        }
        Small  = @{
            Memory     = 2GB
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
    for ($i = 1; $i -le $ClientMachineCount; $i++) {
        Write-host "Creating client number $i" -ForegroundColor Blue
        [int]$prompts = $AvailableOperatingSystems.Count
        New-OptionSet -Options $AvailableOperatingSystems
        $choice = Read-Host -Prompt "Select an available Operating System (1-$($AvailableOperatingSystems.Count))"
 
        if (([int]$choice -gt $prompts) -or ([int]$choice -lt 1)) {
            throw "Invalid option. Please choose between 1 and $prompts!"
        }
        else {
            $OperatingSystem = $AvailableOperatingSystems[($choice - 1)]
        }
 
        New-OptionSet -Options @('Small - (2GB Ram, 2 vCPU)', 'Medium - (8GB Ram, 4 vCPU)', 'Large - (16GB Ram, 4 vCPU)')
        $choice = Read-Host 'Select VM size (1-3)' 
 
        $ClientVMSize = switch ($choice) {
            1 { 'Small' }
            2 { 'Medium' }
            3 { 'Large' }
            default { throw 'Invalid option. Please choose between 1 and 3!' }
             
        }
 
        New-ClientPC -OperatingSystem $OperatingSystem -ResourceSize $ClientVMSize -Count $i
    }

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
                NetworkAdapter           = $nic1, $nic2
                DomainName               = $DomainName
            }
    
            Add-LabMachineDefinition @configuration
        }
    }

    Install-Lab
}