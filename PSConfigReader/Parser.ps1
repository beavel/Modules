function Get-NodeNamesFromXml{
    <#
    Returns the string value of the XML nodes based on type.
    #>
    param(
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='XmlDocument')]
        [System.Xml.XmlDocument]$XML,

        [Parameter(Mandatory=$true,Position=0,ParameterSetName='XmlElement')]
        [System.Xml.XmlElement]$XmlElement,

        [Parameter(Mandatory=$false, Position=1)]
        [ValidateSet("Property")]
        [String]$MemberType = 'Property',

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateSet('System.String','System.Xml.XmlElement','System.Object','All')]
        [String]$DefinitionMatch = 'System.String|string'
    )
    
    switch($PsCmdlet.ParameterSetName){
        'XmlDocument'{$XMLToParse = $XML}
        'XmlElement'{$XMLToParse = $XmlElement}
    }
    [Array]$tmpPropArray = @();
    if($DefinitionMatch.ToUpper() -eq 'ALL'){
        $dm = 'System.String|System.Xml.XmlElement|System.Object'
    }else{
        $dm = $DefinitionMatch
    }
    $tmpPropArray = $XMLToParse | 
        Get-Member -MemberType $MemberType |
        where{$_.Definition -match "$dm"} |
        select -ExpandProperty Name
    return $tmpPropArray
}


function Get-PropertyType{
    [CmdletBinding(DefaultParameterSetName='XmlElement')]
    param(
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='XmlElement')]
        [System.Xml.XmlElement]$XmlElement,
        
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='System.Object')]
        [System.Object[]]$Object
    )
    switch($PsCmdlet.ParameterSetName){
        'XmlElement'{
            return $XmlElement | Get-Member -MemberType Property |
                foreach{$_.Definition.Split(' ')[0]}
        }
        'System.Object'{
            return $Object[0].GetType().FullName
        }
    }
}

function Search-ConfigForPropertyType{
    param(
        [Parameter(Mandatory=$true)]
        [XmlElement]$Config,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Array','Hashtable')]
        [String]$Type
    )

    switch($Type){
        'Array'{
            $definitionType = 'string|System.String'
        }
        'Hashtable'{
            $definitionType = 'System.Xml.XmlElement'
        }
    }

    [Array]$tmpProps = @()
    $xmlParams = @{
        XmlElement = $Config
        DefinitionMatch = 'System.Xml.XmlElement'
    }
    $xmlParameters = Get-NodeNamesFromXml @xmlParams
    if($xmlParameters){
        foreach($xmlParameter in $xmlParameters){
            if($Type -eq 'Array' -and (Test-IsArray -XmlElement $Config.$xmlParameter)){
                $tmpProps += $Config.$xmlParameter
            }

            if($Type -eq 'Hashtable' -and (Test-IsHashtable -XmlElement $Config.$xmlParameter)){
                $tmpProps += $Config.$xmlParameter
            }
        }
    }
    return $tmpProps
}

function Get-AllChildNodes{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param(
        [XmlElement]$Element
    )
    return $Element | Get-Member -MemberType 'Property' `
        | select -Property Name, `
          @{Name="Type";Expression={$_.Definition.Split(' ')[0]}}
}

function Test-IsArray{
    param(
        [XmlElement]$XmlElement
    )
    if($(Get-PropertyType $XmlElement) -eq 'string'){
        return $true
    }

    if($(Get-PropertyType $XmlElement) -eq 'System.xml.XmlElement' -and `
        $XmlElement.HasAttributes -eq $false -and `
        $XmlElement.$($XmlElement | 
                Get-Member -MemberType Property | 
                select -ExpandProperty Name).HasAttributes -eq $false){
        return $true
    }


    $sysObject = Get-NodeNamesFromXml $XmlElement -DefinitionMatch "System.Object"
    if($sysObject -and `
        $(Get-PropertyType $XmlElement.$sysObject) -eq 'System.String')
    {
        return $true
    }

    if($sysObject -and `
        $(Get-PropertyType $XmlElement.$sysObject) -eq 'System.xml.XmlElement' -and `
        $XmlElement.$sysObject[0].HasAttributes -eq $false)
    {
        return $true
    }

    return $false
}

function Test-IsHashtable{
    param(
        [XmlElement]$XmlElement
    )

    if($(Get-PropertyType $XmlElement) -eq 'System.Xml.XmlElement' -and `
        $XmlElement.$($XmlElement | 
                Get-Member -MemberType Property | 
                select -ExpandProperty Name).HasAttributes)
    {
        return $true
    }

    $sysObject = Get-NodeNamesFromXml $XmlElement -DefinitionMatch "System.Object"
    if($sysObject -and `
        $(Get-PropertyType $XmlElement.$sysObject) -eq 'System.Xml.XmlElement' -and `
        $XmlElement.$sysObject[0].HasAttribute('key') -and `
        $XmlElement.$sysObject[0].HasAttribute('value')
        )
    {
        return $true
    }

    return $false
}