# Active Directory Lab

This AutomatedLab provides:

- A Windows Server 2022 Domain Controller
- A Windows 11 client machine
- An optional Chocolatey For Business implementation

## Requirements

- Windows Server 2022 ISO available in Lab Source ISO folder (_defaults to C:\LabSources\ISOs_)
- Windows 11 Enterprise ISO located in the same location

_*OPTIONAL*_

This lab requires the [QuickStartGuide role](..\..\Roles\QuickStartGuide) be installed prior to using this lab. (When using optional Chocolatey Server)

## Installing the Custom Role

1. Create a folder named `QuickStartEnvironment` in C:\LabSources\CustomRoles
2. Copy `helpers.ps1` and `QuickStartEnvironment.ps1` to the folder you created in step 1
3. Copy your certificate `.pfx` file to the folder from Step 1
4. Copy your Chocolatey license file to the folder from Step 1

## VM Sizes

This lab supports customizing the resources available to the VMs being built. The following options are available:

- Small : 2GB Ram / 2 vCPU (_default for ClientVMSize, DomainControllerVMSize_)
- Medium: 8GB Ram / 4 vCPU
- Large: 16GB Ram / 4 vCPU (_default for ChocolateyServerVMSize_)

## Usage

### Directly via Definition.ps1

You can run this definition.ps1 directly

#### Without Chocolatey Server

```powershell
$definitionParameters = @{
    Name = 'ActiveDirectory'
    Credential = Get-Credential
    DomainName = 'steviecoaster.dev'
    DomainControllerVMSize = 'Small'
    IncludeChocolateyServer = $false
 }

.\definition.ps1 @definitionParameters
```

#### With Chocolatey Server

```powershell
$definitionParameters = @{
    Name = 'ActiveDirectory'
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
    IncludeChocolateyServer = $false
 }

New-LabConfiguration -Name ActiveDirectory -Definition .\definition.ps1 -Parameters @definitionParameters
```

#### With Chocolatey Server

```powershell
$definitionParameters = @{
    ServerLogin = Get-Credential
    DomainName = 'steviecoaster.dev'
    DomainControllerVMSize = 'Small'
    IncludeChocolateyServer = $true
    # Chocolatey Server specific requirements
    DatabaseCredential = Get-Credential
    CertificateDnsName = 'chocolatey.steviecoaster.dev'
    $ChocolateyServerVMSize = 'Large'
 }

New-LabConfiguration -Name ActiveDirectory -Definition .\definition.ps1 -Parameters @definitionParameters
```

With a new configuration defined you can start the lab with defaults:

```powershell
Start-Lab -Name ActiveDirectory
```

You can override a configuration parameter value, or provide new parameters by passing `-AdditionalParameters`, which accepts a hashtable.

```powershell
Start-Lab -Name ActiveDirectory -AdditionalParameters @{ ClientVMSize = 'Large' } # Override the ClientVMSize
```

## Removing The Lab

When you're done you can remove the lab by running:

```powershell
Get-Lab | Remove-Lab # -Confirm:$falae to suppress prompts
```

> 📓NOTE📓
> You may need to run `Import-Lab -Name YourLabNameHere`
> prior to removing the lab.
