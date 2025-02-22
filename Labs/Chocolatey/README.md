# Chocolatey Lab

The purpose of this lab is to provide you with an environment that is ready to go for trying out the Chocolatey package manager.
If you would like to use this lab to author Chocolatey Packages, you can do that as well by including the `-IncludeAuthoringTools` switch when running the lab.

If including Authoring tools, this VM will have the following packages installed once the Lab finished building:

- vscode.install
- vscode-powershell
- chocolatey-vscode
- git.install
- notepadplusplus.install
- beyondcompare

## Lab Requirements

### Hardware

This lab requires 4GB Ram and 4 vCPUs (Edit lines 63-64 in lab's definition.ps1 to change. Lower is not recommended)

### Operating System

By default the lab will use 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)', but can be changed with parameters (see next section).

## Customization

You can customize the environment in the following ways:

- `VMName`: This is the hostname of the machine once booted. Defaults to 'SweetTooth'.
- `OperatingSystem`: This is the Operating System the machine will use. Tab completions based on ISOs available in ISOs folder of your LabSources directory (_C:\LabSources\ISOs by default_)
- `IncludeAuthoringTools`: Switch parameter that will install a curated list of packages helpful in authoring Chocolatey Packages.
- `AdditionalPackages`: In addition to the curated list, you can install any additional packages from the Chocolatey Community Repository. Just provide a comma separated list of package ids here. (Latest versions only currently).

## Usage

### Directly from Definition.ps1

You can launch this lab by executing the definition.ps1 file directly.

```powershell
$definitionArgs = @{
Name = 'ChocolateyLab'
OperatingSystem = 'Windows 11 Enterprise Evaluation'
ServerLogin = Get-Credential
VMName = 'ChocoLatte'
IncludeAuthoringTools = $true


.\definition @definitionArgs
```

### Using AutomatedLab.Utils

If you have the [AutomatedLab.Utils module](https://github.com/steviecoaster/AutomatedLab.utils) module installed you can add a new configuration:

```powershell
New-LabConfiguration -Name ChocolateyLab -Definition .\Definition.ps1 -Parameters @{
    OperatingSystem = 'Windows 11 Enterprise Evaluation'
    ServerLogin = Get-Credential
    VMName = 'ChocoLatte'
    IncludeAuthoringTools = $true
}
```

With a new configuration defined you can start the lab with defaults:

```powershell
Start-Lab -Name ChocolateyLab
```

You can override a default, or change the number of client machines by passing `-AdditionalParameters`

```powershell
Start-Lab -Name ChocolateyLab -AdditionalParameters @{ IncludeAuthoringTools = $false }
```

## Removing The Lab

When you're done you can remove the lab by running:

```powershell
Get-Lab | Remove-Lab # -Confirm:$falae to suppress prompts
```

> 📓NOTE📓
> You may need to run `Import-Lab -Name YourLabNameHere`
> prior to removing the lab.
