[CmdletBinding()]
Param(
    [Parameter()]
    [String]
    $Fqdn
)

end {
    $helpers = Join-Path $PSScriptRoot -ChildPath 'helpers.ps1'
    . $helpers

    $IPAddress = (Test-Connection chocoserver -Count 1).IPV4Address.IPAddressToString
    New-HostsFileEntry -IpAddress $IPAddress -Hostname $Fqdn
}