function ConvertFrom-EpochTime{
    param(
        [Parameter(Mandatory=$true)]
        [Long]$Seconds
    )
    (Get-EpochTime).AddSeconds($Seconds).ToLocalTime()
}

function ConvertTo-EpochTime{
    param(
        [Parameter(Mandatory=$true)]
        [DateTime]$DateTime
    )
    $timeSpanParams = @{
        Start = Get-EpochTime
        End = $DateTime.ToUniversalTime()
    }

    [Long](New-TimeSpan @timeSpanParams).TotalSeconds
}

function Get-EpochTime{
    New-Object DateTime -ArgumentList 1970,1,1,0,0,0,([DateTimeKind]::Utc)
}

Export-ModuleMember -Function @(
    'ConvertFrom-EpochTime'
    ,'ConvertTo-EpochTime'
)