# Chocolatey AutomatedLab Definitions

This repository contains a collection of AutomatedLab definitions that I use at work.

## Required Software

To use these labs you need to have a Windows host with [AutomatedLab](https://automatedlab.org) installed, and Hyper-V enabled

Lab hardware requirements available in the respective READMEs.

## Terminology

You'll encounter the following terms throughout this repository. This is what they mean:

- `Lab`: The finished product of executing a definition
- `Definition`: A PowerShell script that defines the "shape" of a Lab. Number of virtual machines, networking, any custom roles or extra "stuff" done while the machine is built up.
- `Role`: Interchangeable with `Custom Role`, this is a folder created in the Lab Sources `CustomRoles` directory (_C:\LabSources\CustomRoles by default_). This folder _must_ contain a `.ps1` script of the same name e.g. an `Inedo` folder must contain `Inedo.ps1`.
- `C4b`: This is Chocolatey For Business
- `Lab Configuration/Configuration`: A file stored on disk as the result of running `New-LabConfiguration`. Used when working with AutomatedLab via the [AutomatedLab.Utils](https://github.com/steviecoaster/AutomatedLab.Utils) PowerShell module.

## Available Labs

### Open Source Labs

The following labs work without requiring a Chocolatey For Business license:

- [Inedo](.\Labs\Inedo\README.md): Provides an Inedo ProGet instance for testing and local development
- [Chocolatey](.\Labs\Chocolatey\README.md): Provides a Chocolatey environment for testing and package authoring.
- [Active Directory](.\Labs\ActiveDirectory\README.md): Provides an Windows Server 2022 Active Directory Environment. (_May require Chocolatey For Business license in some scenarios. See Lab README for details._)


### Licensed Labs

If you have a Chocolatey For Business license you can use the following labs:

- [QuickstartGuide](.\Labs\Licensed\QuickStartEnvironment\README.md): Builds a Lab based on [Chocolatey's Quickstart Guide](https://docs.chocolatey.org/en-us/c4b-environments/quick-start-environment/chocolatey-for-business-quick-start-guide/)
- [Multi-Client](.\Labs\Licensed\Multi-Client\README.md): Builds a Domain Controller, and members based on `$ClientMachineCount`. Optionally include a Chocolatey server.

## Usage

See the README file in each Lab folder for instructions on how to use the Lab. Using [AutomatedLab.Utils](https://github.com/steviecoaster/AutomatedLab.Utils) is highly recommended.

**DISCLAIMER**

The code provided in this repository is all stuff I use personally, is not associated with Chocolatey Software, and cannot be associated with any Support contract(s) you may have when using labs which require a Chocolatey For Business license.

Your mileage may very. Use with caution.
