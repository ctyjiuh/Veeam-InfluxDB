# veeam_job_before
  foreach ($job in Get-VBRJob) {
    $job_name="job_name="+$job.Name
    $job_sessions=(
      Get-VBRBackupSession | Where {$_.jobId -eq $job.Id.Guid} | Where {$_.State -ne "Stopped"}
      )
    foreach ($job_session in $job_sessions) {
      $idfile="C:\dt\log\"+$job_session.ID
      if (!(Test-Path ($idfile))) {
        New-Item $idfile -Type file | Out-Null
        $job_sessionid='job_sessionid="'+$job_session.Id+'"'
        # $job_sessionname='job_sessionname="'+$job_session.Name+'"'
        $job_sessionstarttime="job_sessionstarttime="+'"'+(get-date -Format yyyy-MM-dd:HH-mm $job_session.CreationTime)+'"'
        $job_sessionisfull="job_sessionisfull="+$job_session.IsFullMode
        $titlestring=($job_name) -join ','
        # $valuestring=($job_sessionid,$job_sessionstarttime,$job_sessionisfull,$job_sessionname) -join ','
        $valuestring=($job_sessionid,$job_sessionstarttime,$job_sessionisfull) -join ','
        $outstring="veeam_job,"+$titlestring+" "+$valuestring
        Add-Content $idfile -Value $outstring -NoNewline
        }
      }
    }
