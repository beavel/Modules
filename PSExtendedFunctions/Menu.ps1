function Read-MenuResponse{
    param(
        [Parameter(Mandatory=$true)]
        [String]$Prompt,
        
        [Parameter(Mandatory=$true)]
        [Hashtable]$MenuOptions    
    )
    $menu = $Prompt + ':' + "`r`n`r`n"
    foreach($key in ($MenuOptions.Keys | sort)){
        $menu += "`t" + ("{0}`t:`t{1}" -f $key, $MenuOptions.$key) + "`r`n"
    }
    $skip = 'S'
    $menu += "`t" + ("{0}`t:`t{1}" -f $skip, 'Skip') + "`r`n"

    $i = 0
    do{
        <# Desired output, but complicates return
        if($i -gt 0){
            Write-Output "$answer is not a valid option!" +
                " Please select an option from the menu."
        }#>

        $answer = Read-Host -Prompt $menu
        $i++
    }while((($MenuOptions.Keys -contains $answer) -or 
        ($answer -eq $skip)) -eq $false)

    $tmpAnswer = $null
    if([Int]::TryParse($answer,([REF]$tmpAnswer))){
        $answer = $tmpAnswer
    }

    return $answer
}

Export-ModuleMember -Function @(
    'Read-MenuResponse'
)