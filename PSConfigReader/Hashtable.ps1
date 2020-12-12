function Get-HashtableFromConfigNode{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$ConfigNode
    )
    $tmpConfigHash = @{}
    $strProps = Get-StringProperties $ConfigNode -ExcludedProperty 'Name'
    if($strProps){
        foreach($strProp in $strProps){
            $tmpConfigHash.Add($strProp, $ConfigNode.$strProp)
        }
    }
    $arrayProps = Get-ArrayProperties $ConfigNode
    if($arrayProps){
        foreach($arrayProp in $arrayProps){
            [Array]$tmpArray = @()
            [Array]$tmpArray = Get-ArrayFromXmlElement -XmlElement $arrayProp
            $tmpConfigHash.Add($arrayProp.Name, [Array]$tmpArray)
        }
    }
    
    $hashProps = Get-HashProperties $ConfigNode
    if($hashProps){
        foreach($hashProp in $hashProps){
            [Hashtable]$tmpHash = @{}
            $tmpHash = Get-HashtableFromXmlElement -XmlElement $hashProp
                        
            $tmpConfigHash.Add($hashProp.Name,$tmpHash)
        }
    }

    return $tmpConfigHash
}