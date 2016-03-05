function Invoke-HttpWarmUpRequest{
    param(
        [ValidateScript({[System.Uri]::IsWellFormedUriString($_, [System.UriKind]::Absolute)})]
        [String[]]$Url
    )
    foreach($u in $Url){
        Write-Output ("{0}: Warming up site {1}..." -f (Get-Date),$u)
        $wc = New-Object System.Net.WebClient
        $wc.UseDefaultCredentials = $true
        try{
            $wc.DownloadString($u) | Out-Null
            Write-Output ("{0}: DONE with request." -f (Get-Date))
        }
        catch [System.Management.Automation.MethodInvocationException]{
            Write-Output ("{0}: FAILED! Continuing anyway..." -f (Get-Date))
        }
    }
 }

 Export-ModuleMember -Function @(
    'Invoke-HttpWarmUpRequest'
)