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
    try{
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
        $tmpPropArray = $XMLToParse | Get-Member | `
            where{$_.MemberType -eq "$MemberType" -and $_.Definition -match "$dm"} `
            | foreach{$_.Name.ToString()}
        return $tmpPropArray
    }
    catch{
        #Region ### Logging ###
        $tmpLogEntry = New-LogEntry $XMLToParse.GetType().FullName `
            $("Failed to get XML Property for {0}." `
            -f $DefinitionMatch) 'Error'
        $Log.Add($tmpLogEntry)
        #EndRegion ### End Logging ###
    }
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
            return $XmlElement | Get-Member `
                 | Where-Object {$_.MemberType -like 'Property'} `
                 | select -First 1 | foreach{$_.Definition.Split(' ')[0]}
        }
        'System.Object'{
            return $Object[0].GetType().FullName
        }
    }
}

function Get-PropertyParser{
    [ScriptBlock]$propParser = {
        param($Config, $DefinitionType)
        [Array]$tmpProps = @()
        $xmlParameters = Get-NodeNamesFromXml $Config `
            -DefinitionMatch System.Xml.XmlElement
        if($xmlParameters){
            foreach($xmlParameter in $xmlParameters){
                # array of one single item #
                if($(Get-PropertyType $Config.$xmlParameter) -eq $DefinitionType){
                    $tmpProps += [Hashtable]@{$xmlParameter = $DefinitionType}
                }
                # array of multiple items #
                $sysObject = Get-NodeNamesFromXml $Config.$xmlParameter `
                  -DefinitionMatch "System.Object"
                if($sysObject){
                    if($(Get-PropertyType $Config.$xmlParameter.$sysObject) `
                      -eq $DefinitionType){
                        $tmpProps += [Hashtable]@{$xmlParameter='System.Object'}
                    }
                }
            }
        }
        return $tmpProps
    }
    return $propParser
}

function Get-AllChildNodes{
    param(
        [XmlElement]$Element
    )
    return $Element | gm -MemberType 'Property' `
        | select -Property Name, `
          @{Name="Type";Expression={$_.Definition.Split(' ')[0]}}
}