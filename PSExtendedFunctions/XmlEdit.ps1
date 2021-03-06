﻿function Test-XmlNode{
    param(
        [Parameter(Mandatory=$true,ParameterSetName='ParentNode')]
        [System.Xml.XmlElement]$ParentNode,

        [Parameter(Mandatory=$true,ParameterSetName='CurrentNode')]
        [System.Xml.XmlElement]$CurrentNode,

        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XmlNode,

        [Switch]$MatchByName
    )
    $exists = $false
    switch($PSCmdlet.ParameterSetName){
        'CurrentNode'{
            $exists = $CurrentNode.OuterXml -eq $XmlNode.OuterXml
        }
        'ParentNode'{
            foreach($n in $ParentNode.ChildNodes){
                if($n.OuterXml -eq $XmlNode.OuterXml){
                    $exists = $true
                    break
                }
            }
        }
    }
    return $exists
}

function Get-XPathParentNode{
    param(
        [Parameter(Mandatory=$true)]
        [String]$XPath
    )
    $XPath.Substring(0,$XPath.LastIndexOf('/')).TrimEnd('/')
}

function Set-XmlConfigValue{
    param(
        [Parameter(Mandatory=$true,ParameterSetName='File')]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]$Path,

        [Parameter(Mandatory=$true,ParameterSetName='XML')]
        [ValidateNotNullOrEmpty()]
        [XML]$XML,

        [Parameter(Mandatory=$true)]
        [String]$XPath,

        [Parameter(Mandatory=$true)]
        [String]$XmlNode,

        [ValidateSet('Add','Remove')]
        [String]$Operation = 'Add',

        [Switch]$ResetFileAttributes
    )
    switch($PSCmdlet.ParameterSetName){
        'File'{[XML]$config = Get-Content -Path $Path}
        'XML'{[XML]$config = $XML.Clone()}
    }

    try{
        $updated = $false
        $operationType = ''

        if([String]::IsNullOrEmpty($config.xml)){
            # Set encoding
            $xmlDeclaration = $config.CreateXmlDeclaration('1.0',$null,$null)
            $xmlDeclaration.Encoding = [System.Text.Encoding]::UTF8
        }

        $xmlElem = New-Object System.Xml.XmlDocument
        $xmlElem.LoadXml($XmlNode)
        $newNode = $config.ImportNode($xmlElem.DocumentElement,$true)

        if([String]::IsNullOrEmpty($config.DocumentElement.xmlns)){
            $node = $config.SelectSingleNode("$XPath")
            if($node -eq $null -and ($Operation -eq 'Add')){
                $parentXPath = Get-XPathParentNode -XPath $XPath
                $node = $config.SelectSingleNode($parentXPath)
                $operationType = 'Add'
            }elseif(($node -ne $null) -and ($Operation -eq 'Add')){
                $operationType = 'Update'
            }elseif(($node -ne $null) -and ($Operation -eq 'Remove')){
                $operationType = 'Remove'
            }
        }else{
            $namespace = New-Object XmlNamespaceManager -ArgumentList $config.NameTable
            $namespace.AddNamespace('ns',$config.DocumentElement.xmlns)
            $node = $config.SelectSingleNode("$XPath",$namespace)
            if($node -eq $null -and ($Operation -eq 'Add')){
                $parentXPath = Get-XPathParentNode -XPath $XPath
                $node = $config.SelectSingleNode($parentXPath,$namespace)
                $operationType = 'Add'
            }elseif(($node -ne $null) -and ($Operation -eq 'Add')){
                $operationType = 'Update'
            }elseif(($node -ne $null) -and ($Operation -eq 'Remove')){
                $operationType = 'Remove'
            }
        }
        if($node -ne $null -and $operationType -ne ''){
            switch($operationType){
                'Update'{
                    if( -not(Test-XmlNode -CurrentNode $node -XmlNode $newNode)){
                            $parentNode = $node.ParentNode
                            $parentNode.ReplaceChild($newNode, $node) | Out-Null
                            $updated = $true
                            $changeType = 'Updated'
                        }
                    }

                'Add'{
                    $node.AppendChild($newNode) | Out-Null
                    $updated = $true
                    $changeType = 'Added'
                }

                'Remove'{
                    $paretNode = $node.ParentNode
                    $paretNode.RemoveChild($node) | Out-Null
                    $updated = $true
                    $changeType = 'Removed'
                }
            }
            if($updated -and $PSCmdlet.ParameterSetName -eq 'File'){
                try{
                    # Backup before committing file changes #
                    $newFile = Backup-File -File $Path
                    Write-Output ("{0}: File backed up to {1}..." -f (Get-Date),$newFile)

                    if(Test-FileAttribute -Path $Path -Attribute 'ReadOnly'){
                        $fileAttributes = Get-FileAttributes -Path $Path
                        $desiredAttributes = @($fileAttributes, 'ReadOnly')
                        Set-FileAttributes -Path $Path -Attributes $desiredAttributes
                    }

                    $config.Save($Path)
                    Write-Output ("{0}: {1} node {2} on XPath {3} in {4}..." `
                        -f (Get-Date),$changeType,$XmlNode,$XPath,$Path)
                    if($ResetFileAttributes){
                        Set-FileAttributes -Path $Path -Attributes $fileAttributes
                    }
                }
                catch{
                    Write-Output ("{0}: Save FAILED for {1} when adding node {2} to XPath {3}..." `
                        -f (Get-Date),$Path,$XmlNode,$XPath)
                }
            }elseif($updated -and $PSCmdlet.ParameterSetName -eq 'XML'){
                return $config
            }else{
                Write-Verbose ("{0}: No update needed for {1} node '{2}' already exists..." -f (Get-Date), $Path, $XmlNode)
            }
        }else{
            Write-Verbose ("{0}: No node found in {1} for XPath {2}!" -f (Get-Date), $Path, $XPath)
        }
    }
    catch{
        $msg = Get-DefaultErrorMessage $_
        Write-Output ("{0}: $msg" -f (Get-Date),$msg)
    }

}

Export-ModuleMember -Function @(
    'Set-XmlConfigValue'
)