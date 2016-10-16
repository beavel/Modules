function Get-ArrayProperties{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    $propertyParser = Get-PropertyParser
    return $propertyParser.InvokeReturnAsIs($Config, 'System.String')
}

function Get-HashProperties{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    $propertyParser = Get-PropertyParser
    return $propertyParser.InvokeReturnAsIs($Config, 'System.Xml.XmlElement')
}

function Get-StringProperties{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    return Get-NodeNamesFromXml $Config
}