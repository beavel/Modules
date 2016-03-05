function Get-Sid{
    param($Name)
    $sid = ''
    $objUser = New-Object NTAccount -ArgumentList $Name

    if($objUser -ne $null){
        $sid = $objUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }

    return $sid
}