function Test-IsConfigValid{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlDocument]$Config,
        
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateSet('Environment','ParameterSet')]
        [String]$Type
    )
    $valid = $false
    
    switch($Type){
        'Environment'{
            if((Get-NodeNamesFromXml $Config `
              -DefinitionMatch All) -contains 'Environments'){
              
                if((Get-NodeNamesFromXml $config.SelectSingleNode('//Environments') `
                  -DefinitionMatch All) -contains 'Environment'){
                    $valid=$true
                }
            }
        }
        'ParameterSet'{
            if((Get-NodeNamesFromXml $Config -DefinitionMatch All) -contains 'ParameterSets'){
              
                if((Get-NodeNamesFromXml $config.SelectSingleNode('//ParameterSets') `
                  -DefinitionMatch All) -contains 'ParameterSet'){
                    $valid=$true
                }
            }
        }
    }
    
    return $valid
}

function Test-HasGlobalConfigSection{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.Xml.XmlDocument]$Config
    )
    $hasGlobal = $false
    if($null -ne (Get-GlobalNode $Config)){
        $hasGlobal = $true
    }
    return $hasGlobal
}

function Test-GlobalConfigIsValid{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [XmlElement]$Environment,

        [Parameter(Mandatory=$true,Position=1)]
        [XmlElement]$Global
    )
    $isValid = $false
    if((Get-RootNodeName $Environment) -eq (Get-RootNodeName $Global)){
        $isValid = $true
    }
    return $isValid
}