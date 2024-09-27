function New-HostsFileEntry {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $IPAddress,

        [Parameter(Mandatory)]
        [String]
        $Hostname
    )

    end {
        $entry = '{0}  {1}' -f $IPAddress,$Hostname
        $hostFile = 'C:\Windows\system32\drivers\etc\hosts'
        $entry | Out-File -FilePath $hostFile -Encoding utf8 -Append
    }
}