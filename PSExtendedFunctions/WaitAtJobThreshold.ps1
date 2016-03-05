function Complete-JobProcessing{
    $completedJobs = Get-Job | 
        where { $_.JobStateInfo.State -eq "Completed" }
    
    if($completedJobs -eq $null){
        return
    }
    
    foreach($cj in $completedJobs){
        # Dump the results of any completed jobs
        $jobData = $cj | Receive-Job 2>&1
        
        if($jobData -ne $null){
            Write-Output $jobData
        }
        
        # Remove completed jobs so we don't see their results again
        $cj | Remove-Job
    }
}

function Wait-AtJobThreshold{
    param(
        [Int]$Threshold
    )
    $running = @(Get-Job | where { $_.JobStateInfo.State -eq "Running" })
    while ($running.Count -ge $Threshold) {
        # Block until we get at least one job complete
        $running | Wait-Job -Any | Out-Null
        # Refresh the running job list
        $running = @(Get-Job | where { $_.JobStateInfo.State -eq "Running" })
    }
    Complete-JobProcessing
}

Export-ModuleMember -Function @(
    'Wait-AtJobThreshold'
    ,'Complete-JobProcessing'
)