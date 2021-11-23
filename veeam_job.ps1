# veeam_job
  foreach ($job in Get-VBRJob) {
    $job_name="job_name="+$job.Name
    $job_sessions=(Get-VBRBackupSession | Where {$_.jobId -eq $job.Id.Guid} | Where {$_.State -eq "Stopped"} | Sort CreationTime -Descending | Select -First 50)
    $sent=$false
    $i=0
    while (($sent -eq $false) -and ($i -le 50)){
      $job_session=$job_sessions[$i]
      $job_sessionname="job_sessionname="+'"'+$job_session.Name+'"'
      $idfile="C:\dt\log\"+$job_session.ID
      if ((Test-Path ($idfile)) -And (select-string -path $idfile -Pattern job_sessionresult) -eq $NULL) {
        $job_sessionresult_num=3
        switch ($job_session.Result) {
          Success {$job_sessionresult_num=0}
          Warning {$job_sessionresult_num=1}
          Failed {$job_sessionresult_num=2}
        }
        $job_sessionresult="job_sessionresult="+$job_sessionresult_num
        # $job_sessionduration="job_sessionduration="+($job_session.EndTime-$job_session.CreationTime).TotalSeconds
        $job_sessionduration="job_sessionduration="+$job_session.Progress.Duration.Totalseconds
        $job_sessionAvgSpeed="job_sessionavgspeed="+$job_session.Progress.AvgSpeed
        $job_sessionProcessedSize="job_sessionProcessedSize="+$job_session.Progress.ProcessedSize
        $job_sessionProcessedUsedSize="job_sessionProcessedUsedSize="+$job_session.Progress.ProcessedUsedSize
        $job_sessionReadSize="job_sessionReadSize="+$job_session.Progress.ReadSize
        $job_sessionReadedAverageSize="job_sessionReadedAverageSize="+$job_session.Progress.ReadedAverageSize
        $job_sessionTransferedSize="job_sessionTransferedSize="+$job_session.Progress.TransferedSize
        $job_sessionProcessedObjects="job_sessionProcessedObjects="+$job_session.Progress.ProcessedObjects
        $job_sessionrpo="job_sessionrpo="+((Get-Date)-$job_session.EndTime).TotalSeconds
        $valuestring=($job_sessionname,$job_sessionduration,$job_sessionrpo,$job_sessionresult,$job_sessionAvgSpeed,$job_sessionProcessedSize,$job_sessionProcessedUsedSize,$job_sessionReadSize,$job_sessionReadedAverageSize,$job_sessionTransferedSize,$job_sessionProcessedObjects) -join ','
        Add-Content $idfile -Value "," -NoNewline
        Add-Content $idfile -Value $valuestring -NoNewline
        Get-Content $idfile
        Move-Item $idfile C:\dt\log\arch
        $sent=$true
      } else {$i++}
    }
  }


