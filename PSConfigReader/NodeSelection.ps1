function Get-EnvironmentNode{
    param(
        [Parameter(Mandatory=$true)]
        [XML]$Config,

        [Parameter(Mandatory=$true)]
        [String]$Environment,

        [ValidateRange(1,9)]
        [Int]$Version
    )
    [String]$xpath = ''
    if($PSBoundParameters.ContainsKey('Version')){
        $xpath = "//Environment[@Name='" + $($Environment.ToUpper()) + "'" +
                    " and @Version='" + $($Version.ToString()) + "']"
    }else{
        $xpath = "//Environment[@Name='" + $($Environment.ToUpper()) + "'" +
                    " and not(@Version)]" 
    }
    
    return $Config.SelectSingleNode($xpath)
}

function Get-GlobalNode{
    param([XML]$Config = $Config)
    return $Config.SelectSingleNode("//GlobalVariables")
}

function Get-XMLNode{
    param(
        [XmlElement]$XmlElement,
        [String]$Node
    )
    return $XmlElement.SelectSingleNode("//$Node")
}

function Get-RootNodeName{
    param([XmlElement]$XmlElement)
    [String[]]$tmpNodeName = Get-NodeNamesFromXml $XmlElement `
        -DefinitionMatch System.Xml.XmlElement

    if($tmpNodeName.Count -ne 1){
        throw "Invalid root node! More than one root node."
    }

    return ([String]$tmpNodeName)
}