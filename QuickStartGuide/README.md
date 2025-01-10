# QuickStart Guide Role

This role will provision a VM according to the steps outlined  at https://docs.chocolatey.org/en-us/c4b-environments/quick-start-environment/chocolatey-for-business-quick-start-guide/

**Prior to using this role** 
You _will need_ to provide 2 pieces of information before building a Lab that utilizes this role:

- A pfx certificate for the FQDN you wish to use with your server. This file _must_ be named `cert.pfx` and be placed in the
`$env:AU_LabSource\QuickStartEnvironment` directory
- Your Chocolatey license. Name it `chocolatey.license.xml` and place it in the `$env:AU_LabSource\QuickStartEnvironment` directory

## Example commands to build a Lab

## Build a Lab based off the production (main) branch of Chocolatey's Quickstart Guide repository

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
