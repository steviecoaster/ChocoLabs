# Multi-Client Lab

This AutomatedLab provides:

- A Domain Controller
- A configurable number of member machines
- An optional Chocolatey For Business implementation

## Usage

### Directly via Definition.ps1

You can run this definition.ps1 directly

#### Without Chocolatey Server

```powershell
$definitionParameters = @{
    Credential = Get-Credential
    DomainName = 'steviecoaster.dev'
    DomainControllerVMSize = 'Small'
    ClientMachineCount = 3
    IncludeChocolateyServer = $false
 }

.\definition.ps1 @definitionParameters
```

#### With Chocolatey Server

```powershell
$definitionParameters = @{
    ServerLogin = Get-Credential
    DomainName = 'steviecoaster.dev'
    DomainControllerVMSize = 'Small'
    ClientMachineCount = 3
    IncludeChocolateyServer = $true
    # Chocolatey Server specific requirements
    DatabaseCredential = Get-Credential
    CertificateDnsName = 'chocolatey.steviecoaster.dev'
    $ChocolateyServerVMSize = 'Large'
 }

.\definition.ps1 @definitionParameters
```

### Using AutomatedLab.Utils (Recommended)

If you have the [AutomatedLab.Utils module](https://github.com/steviecoaster/AutomatedLab.utils) module installed you can add a new configuration:

#### Without Chocolatey Server

```powershell
$definitionParameters = @{
    ServerLogin = Get-Credential
    DomainName = 'steviecoaster.dev'
    DomainControllerVMSize = 'Small'
    ClientMachineCount = 3
    IncludeChocolateyServer = $false
 }

New-LabConfiguration -Name MultiClient -Definition .\definition.ps1 -Parameters @definitionParameters
```

#### With Chocolatey Server

```powershell
$definitionParameters = @{
    ServerLogin = Get-Credential
    DomainName = 'steviecoaster.dev'
    DomainControllerVMSize = 'Small'
    ClientMachineCount = 3
    IncludeChocolateyServer = $true
    # Chocolatey Server specific requirements
    DatabaseCredential = Get-Credential
    CertificateDnsName = 'chocolatey.steviecoaster.dev'
    $ChocolateyServerVMSize = 'Large'
 }

New-LabConfiguration -Name MultiClient -Definition .\definition.ps1 -Parameters @definitionParameters
```

With a new configuration defined you can start the lab with defaults:

```powershell
Start-Lab -Name MultiClient
```

You can override a configuration parameter value, or provide new parameters by passing `-AdditionalParameters`, which accepts a hashtable.

```powershell
Start-Lab -Name MultiClient -AdditionalParameters @{ ClientMachineCount = 5 } # Override the ClientMachineCount
```
