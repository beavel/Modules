function New-RandomPassword{
    param(
        [Int]$PasswordLength = 16
    )

    Set-Variable -Name alphaLower -Value "abcdefghijklmnopqrstuvwxyz" -Option Constant
    Set-Variable -Name alphaUpper -Value "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -Option Constant
    Set-Variable -Name numeric -Value "0123456789" -Option Constant

    $characterSet = $alphaLower + $alphaUpper + $numeric

    [String]$randomPassword = ''

    for($i=0;$i -lt $PasswordLength;$i++){
        $rn = Get-Random -Maximum $($characterSet.Length - 1)
        $randomPassword += $characterSet[$rn]
    }

    $randomPassword
}

Export-ModuleMember -Function @(
    'New-RandomPassword'
)