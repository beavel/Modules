function Merge-ConfigNode{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [XmlElement]$Environment,

        [Parameter(Mandatory=$true,Position=1)]
        [XmlElement]$Global
    )
    $tmpConfig = $Null
    if(Test-GlobalConfigIsValid $Environment $Global){
        $tmpConfig = $Environment.Clone()
        $rnName = Get-RootNodeName $Environment
        $gNodes = Get-AllChildNodes $Global.$rnName

        foreach($gn in $gNodes){
            if($null -eq $Environment.$rnName.$($gn.Name)){
                $tmpConfig.$rnName.AppendChild($Global.$rnName.$($gn.Name)) `
                    | Out-Null
            }else{
                Merge-ElementNode `
                    $tmpConfig.$rnName.($gn.Name) `
                    $Global.$rnName.($gn.Name)
            }
        }
    }else{
        throw "Invalid global config section!"
    }
    return $tmpConfig
}

function Merge-ElementNode{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [XmlElement]$Base,

        [Parameter(Mandatory=$true,Position=1)]
        [XmlElement]$Append
    )
    Get-AllChildNodes $Append | foreach{
        $name = $_.Name
        $Append.$name | foreach{
            $Base.AppendChild($_) | Out-Null
        }
    }
}