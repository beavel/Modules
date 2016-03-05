function Test-XmlNode{
    param(
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$ParentNode,

        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]$XmlNode,

        [Switch]$MatchByName
    )
    $exists = $false
    if($MatchByName){
        if($ParentNode["$($XmlNode.ToString())"] -ne $null){
            $exists = $true
        }
    }else{
        foreach($n in $ParentNode.ChildNodes){
            if($n.OuterXml -eq $XmlNode.OuterXml){
                $exists = $true
                break
            }
        }
    }
    return $exists
}

function Set-XmlConfigValue{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]$Path,

        [Parameter(Mandatory=$true)]
        [String]$XPath,

        [Parameter(Mandatory=$true)]
        [String]$XmlNode,

        [ValidateSet('Add','Remove')]
        [String]$Operation = 'Add',

        [Switch]$ResetFileAttributes
    )
    try{
        $fileUpdated = $false
        

        [XML]$webConfig = Get-Content -Path $Path

        # Set encoding
        $xmlDeclaration = $webConfig.CreateXmlDeclaration('1.0',$null,$null)
        $xmlDeclaration.Encoding = [System.Text.Encoding]::UTF8

        $node = $webConfig.SelectSingleNode("$XPath")
        if($node -ne $null){
            $xmlElem = New-Object System.Xml.XmlDocument
            $xmlElem.LoadXml($XmlNode)
            $newNode = $webConfig.ImportNode($xmlElem.DocumentElement,$true)

            if((Test-XmlNode -ParentNode $node -XmlNode $newNode -MatchByName) -and ($Operation -eq 'Add')){
                if( -not(Test-XmlNode -ParentNode $node -XmlNode $newNode)){
                    $oldNode = $node."$($newNode.ToString())"
                    $node.ReplaceChild($newNode, $oldNode) | Out-Null
                    $fileUpdated = $true
                    $changeType = 'Updated'
                }
            }

            if( -not(Test-XmlNode -ParentNode $node -XmlNode $newNode) -and ($Operation -eq 'Add')){
                $node.AppendChild($newNode) | Out-Null
                $fileUpdated = $true
                $changeType = 'Added'
            }

            if((Test-XmlNode -ParentNode $node -XmlNode $newNode) -and ($Operation -eq 'Remove')){
                $oldNode = $node."$($newNode.ToString())"
                $node.RemoveChild($oldNode) | Out-Null
                $fileUpdated = $true
                $changeType = 'Removed'
            }

            if($fileUpdated){
                try{
                    # Backup before committing file changes #
                    $newFile = Backup-File -File $Path
                    Write-Output ("{0}: File backed up to {1}..." -f (Get-Date),$newFile)

                    if(Test-FileAttribute -Path $Path -Attribute 'ReadOnly'){
                        $fileAttributes = Get-FileAttributes -Path $Path
                        $desiredAttributes = @($fileAttributes, 'ReadOnly')
                        Set-FileAttributes -Path $Path -Attributes $desiredAttributes
                    }

                    $webConfig.Save($Path)
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