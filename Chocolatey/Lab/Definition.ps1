[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
    [Parameter(Mandatory, ParameterSetName = 'default')]
    [Parameter(Mandatory, ParameterSetName = 'Author')]
    [String]
    $Name,

    [Parameter(Mandatory, ParameterSetName = 'default')]
    [Parameter(Mandatory, ParameterSetName = 'Author')]
    [PSCredential]
    $ServerLogin,

    [Parameter(ParameterSetName = 'default')]
    [String]
    $VMName = 'SweetTooth',

    [Parameter(ParameterSetName = 'default')]   
    [String]
    [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
        
            $AvailableOperatingSystems = (Get-LabAvailableOperatingSystem).OperatingSystemName

            $AvailableOperatingSystems | ForEach-Object {
                $os = "'$_'"
                if ($WordToComplete -and $os -like "$WordToComplete*") {
                    [System.Management.Automation.CompletionResult]::new($os, $os, 'ParameterValue', $os)
                }
                elseif (-not $WordToComplete) {
                    [System.Management.Automation.CompletionResult]::new($os, $os, 'ParameterValue', $os)
                }
            }
        })]
    $OperatingSystem = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)',

    [Parameter(ParameterSetName = 'default')]
    [Parameter(ParameterSetName = 'Author')]
    [Switch]
    $IncludeAuthoringTools,

    [Parameter(ParameterSetName = 'default')]
    [Parameter(ParameterSetName = 'Author')]
    [String]
    $AdditionalPackages
)

New-LabDefinition -Name $Name -DefaultVirtualizationEngine HyperV
    
#Configure the network for our server
Add-LabVirtualNetworkDefinition -Name 'Default Switch'
$nic1 = New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp

#Set the Lab VM credential
Set-LabInstallationCredential -Username $ServerLogin.Username -Password $ServerLogin.GetNetworkCredential().Password

#Define the server itself in the Lab
$configuration = @{
    Name            = $VMName
    OperatingSystem = $OperatingSystem
    Memory          = 4GB
    Processors      = 4
    NetworkAdapter  = $nic1
}

Add-LabMachineDefinition @configuration

Install-Lab

#Install Chocolatey
Invoke-LabCommand -ComputerName $configuration['Name'] -ScriptBlock {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-RestMethod https://ch0.co/go | Invoke-Expression
} -ActivityName 'Install Chocolatey'

#If auth
switch ($PSCmdlet.ParameterSetName) {
    'Author' {

        $AuthorPack = @('vscode.install'   
            'git.install'
            'vscode-powershell'
            'chocolatey-vscode'
            'notepadplusplus.install'
            'beyondcompare'
        )

        if ($AdditionalPackages) {
            $AuthorPack += $AdditionalPackages
        }

        Invoke-LabCommand -ActivityName 'Install Authoring Tools' -Variable (Get-Variable AuthorPack) -ComputerName $configuration['Name'] -ScriptBlock {
            try {
                choco install $($AuthorPack -join ';') -y --source = 'https://community.chocolatey.org/api/v2'
            }
            catch {
                choco install $($AuthorPack -join ';') -y --source = 'https://community.chocolatey.org/api/v2'
            }
            finally {
                $choco = 'C:\ProgramData\chocolatey\bin\choco.exe'
                $chocoArgs = @('install', ($AuthorPack -join ';'), '-y', "==source='https://community.chocolatey.org/api/v2'")
                & $choco @chocoArgs
            }
        }
    }
}
Write-ScreenInfo -Message 'Restarting VM to refresh PATH/registry/env' -TaskStart
Restart-LabVM -ComputerName $configuration['Name']
Write-ScreenInfo -Message 'VM is now ready for use. Have fun!' -TaskEnd
Write-ScreenInfo -Message 'Package Authoring Tutorials: https://docs.chocolatey.org/en-us/guides/create/'
Write-ScreenInfo -Message 'Questions or need help? Join our Discord! https://ch0.co/community'
