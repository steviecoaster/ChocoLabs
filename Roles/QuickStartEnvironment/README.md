# Role: QuickStartEnvironment

This role automatically provisions a VM according to the steps outline in [Chocolatey's Quick Start Guide](https://docs.chocolatey.org/en-us/c4b-environments/quick-start-environment/chocolatey-for-business-quick-start-guide/).

## Requirements

To use this role you need to provide the following:

- A certificate in `pfx` format with _exportable private keys_
- A Chocolatey For Business License

## Installing the Custom Role

1. Copy this QuickStartEnvironment folder to your LabSources directory (_Defaults to C:\LabSources\CustomRoles_)
2. Copy your certificate `.pfx` file to the folder from Step 1.
3. Copy your Chocolatey license file to the folder from Step 1.
