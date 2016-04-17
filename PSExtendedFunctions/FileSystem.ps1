function Get-UniqueFileName{
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )
    # Handle for existing files; add number to end #
    if(Test-Path $Path -PathType Leaf){
        $i = 1;
        $ext = ([System.IO.FileInfo]$Path).Extension
        $Path = $Path.Replace($ext,"${i}${ext}");
        while(Test-Path $Path -PathType Leaf){
            $Path = $Path.Replace("${i}${ext}","$($i+1)${ext}");
            $i++;
        };
    };
    return $Path
}

function New-Directories{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )
    BEGIN{
        if($ConfirmPreference -eq ‘Low’){
            <#
                User:
                * selected -Confirm
                * has $Global:ConfirmPreference set to Low.
            #>
            $confirmAll = $false
        } else {
            # No -Confirm, so we won’t prompt the user…
            $confirmAll = $true
        }

        $rejectAll = $false
    }
    PROCESS{
        if( -not (Test-Path $Path -PathType Container)){
            if($PSCmdlet.ShouldProcess("Created directory '$Path'.",
                                       "Create directory '$Path'?",
                                       "Creating directory"))
            {
                if($PSCmdlet.ShouldContinue("Do you REALLY want to create the directory '$Path'?",
                                            "Creating '$Path'",
                                            [Ref]$confirmAll, [Ref]$rejectAll))
                {
                New-Item -Path $Path -ItemType Directory -Confirm:$false | Out-Null
                Write-Verbose ("{0}: Created directory $Path" -f (Get-Date))
                }
            }
        }
    }
}

function Backup-File{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [System.IO.FileInfo]$File
    )
    if($File.Exists){
        $date = Get-Date -Format yyyyMMdd_HHmmss
        if([String]::IsNullOrEmpty($File.Extension) -ne $true){
            $ext = $File.Extension
        }else{
            $ext = '.bak'
        }
        $backupFile = $File.FullName + '_' + $date + $ext
        Copy-Item $File.FullName -Destination $backupFile
    }else{
        throw 'File Not Found!'
    }
    return $backupFile
}

Set-Alias -Name mkdirs -Value New-Directories

Export-ModuleMember -Function @(
    'Get-UniqueFileName'
    ,'New-Directories'
    ,'Backup-File'
) -Alias @(
    'mkdirs'
)