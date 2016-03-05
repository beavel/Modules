function Get-FileAttributes{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]$Path
    )
    return (Get-ItemProperty -Path $Path).Attributes
}

function Set-FileAttributes{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]$Path,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [FileAttributes[]]$Attributes
    )

    $file = Get-Item -Path $Path -Force # Force gets hidden files
    $desiredAttributes = Add-FileAttributes -Attributes $Attributes

    $file.Attributes = $desiredAttributes
}

function Add-FileAttributes{
    param(
        [Parameter(Mandatory=$true)]
        [FileAttributes[]]$Attributes
    )
    
    foreach($a in $Attributes){
        $tmpAttribute = $tmpAttribute -bxor $a
    }

    return ([FileAttributes]$tmpAttribute)
}

function Test-FileAttribute{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]$Path,

        [Parameter(Mandatory=$true)]
        [FileAttributes]$Attribute
    )
    $binaryTest = $null
    $binaryTest = (Get-FileAttributes -Path $Path) -band $Attribute

    return ($binaryTest -gt 0)
}

Export-ModuleMember -Function @(
    'Get-FileAttributes',
    'Set-FileAttributes',
    'Test-FileAttribute'
)