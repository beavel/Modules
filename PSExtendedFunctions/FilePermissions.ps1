function New-FileSystemAccessRule{
    param(
        [Parameter(Mandatory=$true)]
        [String]$AccountName,

        [Parameter(Mandatory=$true)]
        [FileSystemRights]$Permissions,

        [ValidateSet('Allow','Deny')]
        [AccessControlType]$AllowDeny = 'Allow'

    )
    try{
        Get-Sid -Name $AccountName | Out-Null
    }
    catch{
        throw 'Invalid AccountName! AccountName provided couldn''t be found on system.'
    }

    return New-Object FileSystemAccessRule `
        -ArgumentList $AccountName, $Permissions, $AllowDeny
}

Set-Alias -Name New-AccessRule -Value New-FileSystemAccessRule

Export-ModuleMember -Function @(
    'New-FileSystemAccessRule'
) -Alias @(
    'New-AccessRule'
)