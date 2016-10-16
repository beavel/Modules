function Get-ArrayProperties{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    $propertyParser = Get-PropertyParser
    return $propertyParser.InvokeReturnAsIs($Config, 'System.String')
}

function Get-HashProperties{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    $propertyParser = Get-PropertyParser
    return $propertyParser.InvokeReturnAsIs($Config, 'System.Xml.XmlElement')
}

function Get-StringProperties{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    return Get-NodeNamesFromXml $Config
}