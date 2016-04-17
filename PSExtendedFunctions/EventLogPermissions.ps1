$eventLogRegLocation = 'HKLM:\SYSTEM\CurrentControlSet\services\eventlog\'

function Set-EventLogPermissions{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
    param(
        [Parameter(Mandatory=$true)]
        [String]$Account,

        [Parameter(Mandatory=$true)]
        [String]$LogName,

        [Parameter(Mandatory=$true,HelpMessage='1=Read,2=Write,4=Clear')]
        [ValidateRange(1,7)]
        [Int]$Permissions,

        [ValidateSet('Allow','Deny')]
        [AccessControlType]$AllowDeny = 'Allow'
    )
    try{
        $accountSid = Get-Sid -Name $Account
    }
    catch{
        throw 'Invalid AccountName! AccountName provided couldn''t be found on system.'
    }
    New-EventLogCustomSecurityDescriptor -LogName $LogName

    $logPath = $eventLogRegLocation + $LogName
    
    try{
        <# Get SDDL:
        $orgSDDL = Get-ItemProperty -Path $logPath -Name CustomSD | 
            select -ExpandProperty CustomSD
        #>

        $orgSDDL = ([xml](wevtutil.exe gl $LogName /f:xml)).channel.channelAccess
        
        # Create ACL
        $acl = New-Object System.Security.AccessControl.RegistrySecurity
        if([String]::IsNullOrEmpty($orgSDDL) -ne $true){
            $acl.SetSecurityDescriptorSddlForm($orgSDDL)
        }

        # Create ACE
        $ace = New-Object RegistryAccessRule -ArgumentList $Account,$Permissions,$AllowDeny

        # Combine ACL
        $acl.AddAccessRule($ace)
        $newSDDL = $acl.SDDL

        # Store SDDL:
        #Set-ItemProperty -Path $logPath -Name CustomSD -Value $newSDDL.Trim()
        
        $cmd = "wevtutil sl $logName /ca:'$newSddl'"
        Invoke-Expression -Command $cmd

        Write-Output ("{0}: Updated CustomSD for {1} from {2} to {3}." `
            -f (Get-Date),$LogName,$orgSDDL,$newSDDL)
    }
    catch{
        Write-Output ("{0}: Failed setting permissions on {1} log for {2}" `
            -f (Get-Date),$LogName,$Account)
    }
}


function New-EventLogCustomSecurityDescriptor{
    param(
        [String]$LogName = 'Application'
    )

    # Compose Key:
    $logPath = $eventLogRegLocation + $LogName
    if(Test-Path $LogPath)
    {
        $customSD = Get-ItemProperty -Path $logPath -Name CustomSD -ea SilentlyContinue
        if([String]::IsNullOrEmpty($customSD)){
            New-ItemProperty -Path $logPath -Name CustomSD `
                -PropertyType ([Microsoft.Win32.RegistryValueKind]::String) |
                Out-Null
        }
    }else{
        Write-Error "Cannot acesss log $LogName"
    }
}

Export-ModuleMember -Function @(
    'Set-EventLogPermissions'
)