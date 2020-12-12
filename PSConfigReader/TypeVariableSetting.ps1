function Set-Boolean{
    param(
		[Parameter(Mandatory=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
		[REF]$Hashtable
	)
    [ScriptBlock]$boolReplace = {
        param([String]$String)
        $bools = @('true','false','$true','$false')
        if($bools -contains $String.ToLower()){
            return [System.Convert]::ToBoolean($String.Replace('$',''))
        }
        return $String
    }
    Update-HashConfig $Hashtable $boolReplace
}

function Set-ScriptBlock{
    param(
		[Parameter(Mandatory=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
		[REF]$Hashtable
	)
    [ScriptBlock]$scriptblockReplace = {
        param([String]$String)
        if($String.StartsWith('{') -and $String.EndsWith('}')){
            return [ScriptBlock]::Create($String.TrimStart('{').TrimEnd('}'))
        }
        return $String
    }
    Update-HashConfig $Hashtable $scriptblockReplace
}

function Set-PlaceHolder{
    param(
        [Parameter(Mandatory=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
		[REF]$Hashtable,

        [Parameter(Mandatory=$true,Position=1)]
        [Hashtable]$ReplacementValues
    )
    [ScriptBlock]$placeHolderReplace = {
        param([String]$String)
        foreach($key in $ReplacementValues.Keys){
            $String = $String.Replace($key, $ReplacementValues.$key)
        }
        return $String
    }

    Update-HashConfig $Hashtable $placeHolderReplace
}

function Update-HashConfig{
	param(
		[Parameter(Mandatory=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
		[REF]$Hashtable,

        [Parameter(Mandatory=$true,Position=1)]
        [ScriptBlock]$ReplaceScript
	)
	[Hashtable]$tmpHashtable = @{}
	foreach($key in $Hashtable.Value.Keys){
		switch($Hashtable.Value.$key.GetType().FullName){
			System.String {
                $tmpHashtable.Add($key, $ReplaceScript.InvokeReturnAsIs($Hashtable.Value.$key))
				break
			}
			System.Collections.Hashtable{
				[Hashtable]$tmpTmpHashtable = @{};
				foreach($tmpKey in $Hashtable.Value.$key.Keys){
                    $tmpTmpHashtable.Add($tmpKey, $ReplaceScript.InvokeReturnAsIs($Hashtable.Value.$key.$tmpKey))
				}
				$tmpHashtable.Add($key, $tmpTmpHashtable)
                break
			}
			{$_ -match "System.Object\[\]|System.Collections.ArrayList"}{
				if(-not [System.String]::IsNullOrEmpty($Hashtable.Value.$key))
                {
                    [Array]$tmpTmpArray = @();
                    $Hashtable.Value.$key | foreach{
                        if($_.GetType().FullName -eq 'System.Collections.Hashtable')
                        {
                            Update-HashConfig -Hashtable ([REF]$_) -ReplaceScript $ReplaceScript
                            $tmpTmpArray += $_
                        }
                        else
                        {
                            $tmpTmpArray += $ReplaceScript.InvokeReturnAsIs($_)}
                        }
    				$tmpHashtable.Add($key, $tmpTmpArray)
                }
			}
            default{
                $tmpHashtable.Add($key, $Hashtable.Value.$key)
            }
		}
	}
	$Hashtable.Value = $tmpHashtable
}