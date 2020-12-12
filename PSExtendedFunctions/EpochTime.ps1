function ConvertFrom-EpochTime{
    param(
        [Parameter(Mandatory=$true,ParameterSetName='Seconds')]
        [Long]$Seconds,

        [Parameter(Mandatory=$true,ParameterSetName='Milliseconds')]
        [Long]$Milliseconds,

        [Switch]$InUtcTime
    )
    switch($PSCmdlet.ParameterSetName){
        'Seconds'{
            $date = (Get-EpochTime).AddSeconds($Seconds)
        }
        'Milliseconds'{
            $date = (Get-EpochTime).AddMilliseconds($Milliseconds)
        }
    }

    if($InUtcTime){
        $date.ToUniversalTime()
    }else{
        $date.ToLocalTime()
    }
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