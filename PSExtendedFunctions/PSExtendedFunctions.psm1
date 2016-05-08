##############################################################################
##
## PSExtendedFunctions
##
## Created by: Brian Vander Lugt
##
## Description: Location to place reusable functions for general PowerShell.
##
##############################################################################

Push-Location -Path "$(Split-Path -Parent $MyInvocation.MyCommand.Path)"
. .\Utility.ps1

[Hashtable]$typeAccelerators = @{
    AccessControlType     = 'System.Security.AccessControl.AccessControlType'
    FileAttributes        = 'System.IO.FileAttributes'
    FileSystemAccessRule  = 'System.Security.AccessControl.FileSystemAccessRule'
    FileSystemRights      = 'System.Security.AccessControl.FileSystemRights'
    RegistryAccessRule    = 'System.Security.AccessControl.RegistryAccessRule'
    XmlNamespaceManager  = 'System.Xml.XmlNamespaceManager'
}

Set-ExtendedTypeAccelerators $typeAccelerators

if($PSVersionTable.PSVersion.Major -gt 2){
    Get-ChildItem -Path * -Include *.ps1 -Exclude *Tests* | 
        where{$_.Name -ne 'Utility.ps1'} | 
        foreach{. $_.FullName}
}else{
    Get-ChildItem -Path * -Include *.ps1 | 
        where{@('Utility.ps1','CompressDirectoryToZip.ps1') -notcontains $_.Name} | 
        foreach{. $_.FullName}
}
Pop-Location