function Get-Sid{
    param($Name)
    $sid = ''
    [NTAccount]$objUser = New-Object NTAccount -ArgumentList $Name

    if($objUser -ne $null){
        $sid = $objUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }

    return $sid
}