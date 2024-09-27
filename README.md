# Chocolatey AutomatedLab Definitions

This repository contains a collection of AutomatedLab definitions that I use at work.

## Installing Automated Lab

You'll need AutomatedLab for this. Learn how to install it on their [docs site](https://automatedlab.org/en/latest/Wiki/Basic/install/).

## Configuring a Custom role

Custom roles are created by creating a folder in `C:\LabSources\CustomRoles`, or wherever you have configured your `LabSources` directory
Once you've created your folder, place a ps1 file of the _same name_ inside the folder.

E.g. to create a Custom Role called `MyCustomRole`, you'd do something like this:

```powershell
$null = New-Item C:\LabSources\CustomRoles\MyCustomRole -ItemType Directory
$null = New-Item C:\Lab\Sources\CustomRoles\MyCustomRole\MyCustomRole.ps1 -ItemType File
```

You can place any additional PowerShell scripts, files, or folders inside the directory you created.
It will be copied to the VM as part of the PostInstallationActivity, and the ps1 file you created will
server as the entry point for interacting with the other files and folders.

For example, the QuickStartGuide Role that I created has my chocolatey license and pfx file contained in my LabSources folder.

## Creating a Lab Definition

You'll find a sample lab definition which implements my QuickStartGuide role in the Lab folder called `Definition.ps1`.