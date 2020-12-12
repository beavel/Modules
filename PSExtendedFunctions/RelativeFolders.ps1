function Get-IISRootWebDirectory{
    return (Get-ItemProperty HKLM:\Software\Microsoft\InetStp\).PathWWWRoot.TrimEnd('\')
}

Export-ModuleMember -Function @(
    'Get-IISRootWebDirectory'
)