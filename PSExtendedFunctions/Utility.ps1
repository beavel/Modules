function Set-Constant{
	param(
		[Parameter(Mandatory=$true,Position=0)]
		[String]$ConstantName,
        
		[Parameter(Mandatory=$true,Position=1)]
		[String]$Value
	)
	if(!(Test-Path Variable:Global:$ConstantName)){
		Set-Variable -Name $ConstantName -Option Constant `
			-Value $Value -Scope Global
	}
}

function Test-ElevatedPrivileges{
	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( `
		[Security.Principal.WindowsIdentity]::GetCurrent())
		
	if(-not $currentPrincipal.IsInRole( `
	  [Security.Principal.WindowsBuiltInRole]::Administrator)){
	  
		$returnMessage = "Script must run as Administrator. "
		$returnMessage += "Please re-run with Administrator privileges."
		Write-Host -ForegroundColor Red $returnMessage
		exit 
	}
}

function Get-CurrentUserName{
    return [Environment]::UserDomainName + "\" + [Environment]::UserName
}

function Set-ExtendedTypeAccelerators{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Hashtable]$typeAccelerators
    )
    $xlr8r = [PSObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
    foreach($key in $typeAccelerators.Keys){
        if( -not ($xlr8r::Get).ContainsKey($key)){
            $xlr8r::Add($key,$typeAccelerators.$key)
        }
    }
}

Export-ModuleMember -Function @(
    'Set-Constant'
    ,'Test-ElevatedPrivileges'
    ,'Get-CurrentUserName'
    ,'Set-ExtendedTypeAccelerators'
)