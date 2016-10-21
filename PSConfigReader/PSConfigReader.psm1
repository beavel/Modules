# Load Dependencies #
$name = 'PSExtendedFunctions'
if(-not(Get-Module -name $name)){
    if(Get-Module -ListAvailable | Where-Object { $_.name -eq $name }){
        Import-Module -Name $name -DisableNameChecking
    } #end if module available then import
}

[Hashtable]$typeAccelerators = @{
    XmlElement = 'System.Xml.XmlElement'
}
Set-ExtendedTypeAccelerators $typeAccelerators

Push-Location -Path "$(Split-Path -Parent $MyInvocation.MyCommand.Path)"
Get-ChildItem -Path * -Include *.ps1 -Exclude *Tests* | foreach{. $_.FullName}
Pop-Location