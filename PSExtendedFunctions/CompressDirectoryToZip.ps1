#Requires -version 3.0

function Compress-DirectoryToZip{
    Param(
      [Parameter(Mandatory=$true,ParameterSetName='Pipeline',ValueFromPipeline=$true)]
      [ValidateScript({Test-Path -Path $_ -PathType Container})]
      [String[]]$SourceDirectories,
      
      [Parameter(Mandatory=$true,ParameterSetName='SingleDirectory')]
      [ValidateScript({Test-Path -Path $_ -PathType Container})]
      [String]$SourceDirectory,

      [Parameter(Mandatory=$true,ParameterSetName='SingleDirectory')]
      [String]$DestinationFileName,

      [Parameter(Mandatory=$false)]
      [String]$CompressionLevel = "Optimal",

      [Parameter(Mandatory=$false)]
      [Switch]$IncludeParentDirectory,

      [Switch]$RemoveOnCompletion
    )
    BEGIN{
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        switch($PSCmdlet.ParameterSetName){
            'SingleDirectory'{SourceDirectories = $SourceDirectory}
        }
    }
    PROCESS{
        foreach($dir in $SourceDirectories){
            try{
                if($PSCmdlet.ParameterSetName -eq 'Pipeline'){
                    $DestinationFileName = ("{0}{1}.zip" -f $dir.Substring(0,$dir.LastIndexOf($dir.Split('\')[-1])),
                       $dir.Split('\')[-1])
                    #$DestinationFileName = ("{0}\{1}.zip" -f $dir,$dir.Split('\')[-1])
                }
                Write-Verbose ("{0}: Zipping {1} to {2}." -f (Get-Date),$dir,$DestinationFileName)
                $CompressionLevel = [System.IO.Compression.CompressionLevel]::$CompressionLevel  
                [System.IO.Compression.ZipFile]::CreateFromDirectory(
                    $dir, $DestinationFileName, $CompressionLevel, $IncludeParentDirectory)
                
                if($RemoveOnCompletion){
                    Remove-Item -Path $dir -Recurse -Force
                }
            }
            catch{
                if($RemoveOnCompletion){
                    Write-Output "Directory $dir not removed due to error!"
                }
                throw $_
            }
        }
    }
}

Export-ModuleMember -Function @(
    'Compress-DirectoryToZip'
)