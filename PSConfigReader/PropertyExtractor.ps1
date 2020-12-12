function Get-ArrayProperties{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    $tmpArrays = Search-ConfigForPropertyType -Config $Config -Type Array
    return $tmpArrays
}

function Get-HashProperties{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config
    )
    $propertyParser = Search-ConfigForPropertyType -Config $Config -Type Hashtable
    return $propertyParser
}

function Get-StringProperties{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$Config,

        [Parameter(Mandatory=$false,Position=1)]
        [String[]]$ExcludedProperty
    )
    return (Get-NodeNamesFromXml $Config) | where{$ExcludedProperty -notcontains $_}
}