# QuickStart Guide Lab

This role will provision a VM according to the steps outlined at https://docs.chocolatey.org/en-us/c4b-environments/quick-start-environment/chocolatey-for-business-quick-start-guide/

## Requirements

This lab requires Requires [QuickStartGuide role](..\..\Roles\QuickStartGuide) be installed prior to using this lab

**Prior to using this role** 
You _will need_ to provide 2 pieces of information before building this Lab:

- A pfx certificate for the FQDN you wish to use with your server. This file _must_ be named `cert.pfx` and be placed in the
`$env:AU_LabSource\QuickStartEnvironment` directory
- Your Chocolatey license. Name it `chocolatey.license.xml` and place it in the `$env:AU_LabSource\QuickStartEnvironment` directory

## Installing the Custom Role

1. Create a folder named `QuickStartEnvironment` in C:\LabSources\CustomRoles
2. Copy `helpers.ps1` and `QuickStartEnvironment.ps1` to the folder you created in step 1
3. Copy your certificate `.pfx` file to the folder from Step 1
4. Copy your Chocolatey license file to the folder from Step 1


## VM Sizes

This lab supports customizing the resources available to the VMs being built. The following options are available:

- Small : 2GB Ram / 2 vCPU (_default for ClientVMSize_)
- Medium: 8GB Ram / 4 vCPU
- Large: 16GB Ram / 4 vCPU (_default for ChocolateyServerVMSize_)

## Usage

### Directly from Definition.ps1

```powershell
$LabParams = @{
    Credential = Get-Credential -Message 'Provide credentials for server login'
    DatabaseCredential = Get-Credential -Message 'Provide credentials for CCM Database that will be created'
    CertificateDnsName = 'chocolatey.fabrikam.com' #This is typically the subject (CN) of your PFX file
    #TestBranch = '123' # Uncomment this line and provide the Pull Request id if wanting to try a lab with bleeding edge changes
    #WARNING TestBranch usage may be EXTREMELY unstable.
}
. .\Definition.ps1 @LabParams
```

### Using AutomatedLab.Utils (Recommended)

### Using AutomatedLab.Utils

If you have the [AutomatedLab.Utils module](https://github.com/steviecoaster/AutomatedLab.utils) module installed you can add a new configuration:

```powershell
New-LabConfiguration -Name QuickStartEnvironment -Definition .\Definition.ps1 -Parameters @{
    ServerLogin = Get-Credential
    DatabaseCredential = Get-Credential
    CertificateDnsName = 'chocolatey.fabrikam.com'
    # ChocolateyServerVMSize = 'Large'
    # ClientVMSize = 'Medium'
}
```

With a new configuration defined you can start the lab with defaults:

```powershell
Start-Lab -Name QuickStartEnvironment
```

You can override a default, or change the number of client machines by passing `-AdditionalParameters`

```powershell
Start-Lab -Name QuickStartEnvironment -AdditionalParameters @{ ClientVMSize = 'Large' }
```

## Removing The Lab

When you're done you can remove the lab by running:

```powershell
Get-Lab | Remove-Lab # -Confirm:$falae to suppress prompts
```

> 📓NOTE📓
> You may need to run `Import-Lab -Name YourLabNameHere`
> prior to removing the lab.
