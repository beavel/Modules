function ConvertTo-NormalizedCsv{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]$Path
    )
    $fileInfo = [System.IO.FileInfo]$Path
    $outputFile = $fileInfo.DirectoryName + '\' + $fileInfo.BaseName +
        'Normalized' + $fileInfo.Extension
    Out-File -FilePath $outputFile -Force -Encoding utf8
    
    $file = Get-Content -Path $Path
    $max = $file | foreach{($_.Split(',')).Count} | 
        measure -Maximum | select -ExpandProperty Maximum

    $file | foreach{
        $commasToAdd = $max - ($_.Split(',').Count)
	    $tmpLine = $_
	
        for($i=0;$i -lt $commasToAdd;$i++){
		        $tmpLine = ',' + $tmpLine
	    }

	    $tmpLine | Out-File -PSPath $outputFile -Append -Encoding UTF8
    }
}

Export-ModuleMember -Function @(
    'ConvertTo-NormalizedCsv'
)