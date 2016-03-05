function Get-DotNetVersions{
    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
        Get-ItemProperty -name Version -EA 0 |
        Where { $_.PSChildName -match '^(?!S)\p{L}'} |
        Select PSChildName, Version |
        Sort Version
}

Export-ModuleMember -Function @(
    'Get-DotNetVersions'
)