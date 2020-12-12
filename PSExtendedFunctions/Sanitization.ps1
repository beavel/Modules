function Remove-TabsAndNewLines{
    param([Parameter(Mandatory=$true,Position=0,ValueFromPipeline = $true)]
        [String]$String
    )
    return $String.Replace("`t","").Replace("`n","")
}

function Convert-InvalidPathCharacters{
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline = $true)]
        [String]$String,
        
        [Switch]$Reverse,
        
        [Switch]$FileName
    )
    if($Reverse){
        [Regex]::Matches($String, '_x(?<charInt>\d+)_')| foreach{
            $String = $String.Replace( `
              [String](("_x{0}_") -f $_.Groups['charInt'].Value), `
              [String][Convert]::ToChar(([Int16]$_.Groups['charInt'].Value)))
        }
    }else{
        if($FileName){
            [Array]$invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
        }else{
            [Array]$invalidChars = [System.IO.Path]::GetInvalidPathChars()
        }
        $invalidChars | foreach{
            if($String.Contains($_)){
                $String = $String.Replace([String]$_,[String](("_x{0}_") -f [Convert]::ToByte($_)))
            }
        }
    }
    return $String
}

Export-ModuleMember -Function @(
    'Remove-TabsAndNewLines'
    ,'Convert-InvalidPathCharacters'
)