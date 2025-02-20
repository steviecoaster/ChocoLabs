# Multi-Client Lab

This AutomatedLab provides:

- A Domain Controller
- A configurable number of member machines
- An optional Chocolatey For Business implementation

## Usage

### Directly

You can run this definition.ps1 directly

```powershell

$definitionParameters = @{
    Credential = Get-Credential
    DatabaseCredential = Get-Credential
    CertificateDnsName = 'chocolatey.steviecoaster.dev'
    DomainName = 'steviecoaster.dev'
    DomainControllerVMSize = 'Small'
    ClientMachineCount = 3
    IncludeChocolateyServer = $false
 }


.\definition.ps1 @definitionParameters
```

### AutomatedLab.Utils

If you have the [AutomatedLab.Utils module](https://github.com/steviecoaster/AutomatedLab.utils) module installed you can add a new configuration:

```powershell
New-LabConfiguration -Name MultiClient -Definition .\definition.ps1 -Parameters @{Credential = Get-Credential ; DatabaseCredential = Get-Credential ; CertificateDnsName = 'chocolatey.steviecoaster.dev' ; DomainName = 'steviecoaster.dev' ; DomainControllerVMSize = 'Small' ; ClientMachineCount = 3 ; IncludeChocolateyServer = $false}
```

With a new configuration defined you can start the lab with defaults:

```powershell
Start-Lab -Name MultiClient
```

You can override a default, or change the number of client machines by passing `-AdditionalParameters`

```powershell
Start-Lab -Name MultiClient -AdditionalParameters @{ ClientMachineCount = 20 } # Count here is just an example
```
