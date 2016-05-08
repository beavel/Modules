function Copy-File{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Servers,

        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [Alias('File','FilePath')]
        [String]$Path,

        [Parameter(Mandatory=$true)]
        [String]$DestinationPath,

        [Parameter(Mandatory=$false)]
        [PSCredential]$Credential
    )

    BEGIN{
        if($DestinationPath.EndsWith('\')){
            $DestinationPath = $DestinationPath.TrimEnd('\')
        }

        $fileName = Split-Path -Path $Path -Leaf
        $remotePath = $DestinationPath + '\' + $fileName

        $DestinationPath = $DestinationPath.Replace(':','$')

        Push-Location -Path $PSScriptRoot
    }

    PROCESS{
        foreach($server in $Servers){
            try{
                $psDrive = $null
                #Copy file
                if($server.Contains('.')){
                    $driveName = $server.Split('.')[0]
                }else{
                    $driveName = $server
                }

                $driveParams = @{
                    Name = $driveName
                    PSProvider = 'FileSystem'
                    Root = '\\' + $server + '\' + $DestinationPath
                }

                if($PSBoundParameters.ContainsKey('Credential')){
                    $driveParams.Add('Credential',$Credential)
                }

                $psDrive = New-PSDrive @driveParams
                Copy-Item -Path $Path -Destination "$($driveName):"
            
            }

            finally{
                if($psDrive){
                    Remove-PSDrive -Name $driveName
                }
            }
        }
    }

    END {
        Pop-Location
    }
}

Export-ModuleMember -Function @(
    'Copy-File'
)