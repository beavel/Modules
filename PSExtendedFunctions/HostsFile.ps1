function Test-HostFileForUrl{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateScript({$_ -match '^[^\s]+(?:[.][^\s]+){0,2}$'})]
        [String]$Url,
        
        [Parameter(Mandatory=$false,Position=1)]
        [String[]]$hostFile = $(Get-Content 'C:\Windows\System32\drivers\etc\hosts')
    )
    $present = $false
    $pattern = "^([#]?(\d{1,3}[.]?){4})\b.*${url}\s*$"
    if($hostFile | where{$_ -match $pattern}){
        $present = $true
    }
    return $present
}

function Write-UrlToHostsFile{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateScript({$_ -match '^[^\s]+(?:[.][^\s]+){0,2}$'})]
        [String[]]$Urls,
        
        [Parameter(Mandatory=$false)]
        [ValidateScript({$_ -match '(?:\d{1,3}\.){3}\d{1,3}'})]
        [String]$IpAddress = '127.0.0.1'
    )
    $hostsPath = 'C:\Windows\System32\drivers\etc\hosts'
    $backupFile = Backup-File $hostsPath
    foreach($url in $Urls){
        $hostsFile = Get-Content $hostsPath
        if(Test-HostFileForUrl $url $hostsFile){
            $pattern = "^[#]?(\d{1,3}[.]?){4}.*${url}\s*$"
            $oldEntry = $hostsFile -match $pattern | select -First 1
            $newEntry = $oldEntry -replace '([#]?(?:\d{1,3}[.]?){4})',$IpAddress
            if($oldEntry -ne $newEntry){
                $hostsFile = $hostsFile | Out-String
                $hostsFile = $hostsFile.Replace($oldEntry, $newEntry)
                Out-File -InputObject $hostsFile -FilePath $hostsPath -Encoding ASCII -Force
                Write-Output ("Updated host entry from {0} to {1}" -f $oldEntry, $newEntry)
            }else{
                Write-Verbose ("Entry {0} already present! Skipping..." -f $oldEntry)
                Remove-Item -Path $backupFile
            }
        }else{
            Add-Content -Path $hostsPath -Value "`r`n${IpAddress}`t${url}"
            Write-Output "Added $url to hosts file"
        }
    }
}

Export-ModuleMember -Function @(
    'Test-HostFileForUrl'
    ,'Write-UrlToHostsFile'
)