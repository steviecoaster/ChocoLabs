# Role: QuickStartClient

This role prepares a VM to be used with a VM setup withe QuickStartEnvironment role.

It sets the hosts file to the CertificateDnsName in use by the Chocolatey Server to allow for communication between them when DNS is not available.

## Requirements

None

## Installation

1. Copy this entire QuickStartClient folder to your Lab source's CustomRoles directory (_Defaults to C:\LabSources\CustomRoles)
