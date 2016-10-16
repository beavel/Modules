function Get-HashtableFromConfigNode{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlElement]$ConfigNode
    )
    $tmpConfigHash = @{}
    $strProps = Get-StringProperties $ConfigNode
    if($strProps){
        foreach($strProp in $strProps){
            if($strProp -ne 'Name'){
                $tmpConfigHash.Add($strProp, $ConfigNode.$strProp)
            }
        }
    }
    $arrayProps = Get-ArrayProperties $ConfigNode
    if($arrayProps){
        foreach($arrayProp in $arrayProps){
            [Array]$tmpArray = @()
            $finalProp = Get-NodeNamesFromXml $($ConfigNode.$($arrayProp.Keys)) `
              -DefinitionMatch $arrayProp.Values
            [Array]$tmpArray = $ConfigNode.$($arrayProp.Keys).$finalProp
            $tmpConfigHash.Add($($arrayProp.Keys), [Array]$tmpArray)
        }
    }
    
    $hashProps = Get-HashProperties $ConfigNode
    if($hashProps){
        foreach($hashProp in $hashProps){
            [Hashtable]$tmpHash = @{}
            $finalProp = Get-NodeNamesFromXml $($ConfigNode.$($hashProp.Keys)) `
              -DefinitionMatch $hashProp.Values
            foreach($elem in $ConfigNode.$($hashProp.Keys).$finalProp){
                $tmpHash.Add($elem.Key, $elem.Value)
            }
            $tmpConfigHash.Add($($hashProp.Keys),$tmpHash)
        }
    }

    return $tmpConfigHash
}