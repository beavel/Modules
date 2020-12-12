function New-EnvironmentConfig{
    param(
        [Parameter(Mandatory=$true, ParameterSetName='Path', Position=0,
            HelpMessage = "Enter a path to the XML config")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if($_.StartsWith('.\')){
                $p = $(Get-Location).ToString() + $_.Replace('.\','\')
                Test-Path -Path $p -PathType Leaf
            }else{
                Test-Path -Path $_ -PathType Leaf
            }})]
        [String]$ConfigPath,

        [Parameter(Mandatory=$true, ParameterSetName='XML', Position=0,
            HelpMessage = "Enter an XML variable.")]
        [ValidateNotNullOrEmpty()]
        [XML]$ConfigXML,

        [ValidateRange(1,9)]
        [Int]$Version,

        [Switch]$ReturnAsIs,
        [Switch]$MergeGlobal
    )

    ## Taken from: http://blogs.technet.com/b/pstips/archive/2014/06/10/dynamic-validateset-in-a-dynamic-parameter.aspx
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'Environment'

            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1
            $ParameterAttribute.ParameterSetName = "__AllParameterSets"

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet
            $values = $EnvironmentList
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($values)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    BEGIN{
        switch($PsCmdlet.ParameterSetName){
            'Path'{[XML]$config = Get-Content -Path $ConfigPath}
            'XML'{[XML]$config = $ConfigXML}
        }

        # Bind the parameter to a friendly variable
        $Environment = $PsBoundParameters[$ParameterName]
    }

    PROCESS{
        $configParams = @{
            Config = $config
            Environment = $Environment
        }

        if($PSBoundParameters.ContainsKey('Version')){
            $configParams.Add('Version',$Version)
        }

        ### Execute ###
        if(Test-IsConfigValid $Config -Type Environment){
            if(Test-HasGlobalConfigSection $config){
                $globalNode = Get-GlobalNode $config
                $envConfig = Get-EnvironmentNode @configParams
                if($MergeGlobal){
                    $envConfig = Merge-ConfigNode $envConfig $globalNode
                }
            }else{
                $envConfig = Get-EnvironmentNode @configParams
            }
            $envConfig.RemoveAllAttributes()

            if($ReturnAsIs){
                return $envConfig
            }

            $configHash = @{}
            $configHash = Get-HashtableFromConfigNode $envConfig
            Set-ScriptBlock ([REF]$configHash)
            Set-Boolean ([REF]$configHash)

            if($globalNode){
                $globals = Get-HashtableFromConfigNode $globalNode
                Set-Boolean ([REF]$globals)
                $configHash.Add('Global', $globals)
            }
        }else{
            throw "Invalid Config!"
        }
        $configHash
    }
}

function New-ParameterSetConfig{
    param(
        [Parameter(Mandatory=$true, ParameterSetName='Path', Position=0,
            HelpMessage = "Enter a path to the XML config")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if($_.StartsWith('.\')){
                $p = $(Get-Location).ToString() + $_.Replace('.\','\')
                Test-Path -Path $p -PathType Leaf
            }else{
                Test-Path -Path $_ -PathType Leaf
            }})]
        [String]$ConfigPath,

        [Parameter(Mandatory=$true, ParameterSetName='XML', Position=0,
            HelpMessage = "Enter an XML variable.")]
        [ValidateNotNullOrEmpty()]
        [XML]$ConfigXML,

        [Parameter(Mandatory=$false, Position=1)]
        [Hashtable]$ReplaceValues
    )

    switch($PsCmdlet.ParameterSetName){
        'Path'{[XML]$config = Get-Content -Path $ConfigPath}
        'XML'{[XML]$config = $ConfigXML}
    }
    $parameterSets = @()

    if(Test-IsConfigValid $Config -Type ParameterSet){
        foreach($ps in $config.ParameterSets.ParameterSet){
            [Hashtable]$tmpHashConfig = Get-HashtableFromConfigNode $ps

            if($ReplaceValues -ne $null){
                Set-PlaceHolder ([REF]$tmpHashConfig) $ReplaceValues
            }

            Set-Boolean ([REF]$tmpHashConfig)
            Set-ScriptBlock ([REF]$tmpHashConfig)

            if(Test-HasGlobalConfigSection $config){
                $globals = Get-HashtableFromConfigNode $(Get-GlobalNode $config)

                if($ReplaceValues -ne $null){
                    Set-PlaceHolder ([REF]$globals) $ReplaceValues
                }

                Set-Boolean ([REF]$globals)
                $tmpHashConfig.Add('Global', $globals)

            }
            $parameterSets += $tmpHashConfig
        }
    }else{
        throw "Invalid config!"
    }
    return $parameterSets
}
#EndRegion

Export-ModuleMember -Function 'New-EnvironmentConfig','New-ParameterSetConfig'