function Get-ArrayFromXmlElement{
    param(
        [XmlElement]$XmlElement
    )
    $propertyName = $XmlElement |
        Get-Member -MemberType Property |
        select -ExpandProperty Name

    switch($propertyName.GetType().FullName){
        'System.String'{
            $throwInvalidProperty = [String]::IsNullOrEmpty($propertyName)
        }
        'System.Object[]'{$throwInvalidProperty = $propertyName.Count -ne 1}
        default{
            $throwInvalidProperty = $true
        }
    }

    if($throwInvalidProperty)
    {
        throw "Missing nodes or multiple node names used"
    }
    $arrayElement = $XmlElement.$propertyName
    if($arrayElement[0].GetType().FullName -eq 'System.Xml.XmlElement' `
        -and (Test-IsHashtable -XmlElement $arrayElement[0]))
    {
        $tmpArray = @()
        foreach($hash in $arrayElement){
            $tmpArray += Get-HashtableFromXmlElement -XmlElement $hash
        }
        return $tmpArray
    }else{
        return ([Array]$arrayElement)
    }
}

function Get-HashtableFromXmlElement{
    param(
        [XmlElement]$XmlElement
    )
    $propertyName = $XmlElement |
        Get-Member -MemberType Property |
        select -ExpandProperty Name
    
    
    switch($propertyName.GetType().FullName){
        'System.String'{
            $throwInvalidProperty = [String]::IsNullOrEmpty($propertyName)
        }
        'System.Object[]'{$throwInvalidProperty = $propertyName.Count -ne 1}
        default{
            $throwInvalidProperty = $true
        }
    }

    if($throwInvalidProperty)
    {
        throw "Missing nodes or multiple node names used"
    }

    [Hashtable]$tmpHash = @{}
    foreach($elem in $XmlElement.$propertyName){
        if($elem.HasAttribute('key') -and $elem.HasAttribute('value')){
            $tmpHash.Add($elem.Key, $elem.Value)
        }else{
            throw "Missing 'key' or 'value' attribute on element"
        }
    }

    $tmpHash
}