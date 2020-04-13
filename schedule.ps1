$O = New-ScheduledJobOption -MultipleInstancePolicy "StopExisting"
$T = New-JobTrigger -AtLogOn -User SMTST -RepetitionInterval (New-TimeSpan -Minutes 2) -RepetitionDuration (New-TimeSpan -Hours 8)
Register-ScheduledJob -Name "\SMTST\WifiDetector" -FilePath "C:\Users\SMTST\Documents\WifiDetector.ps1" -Trigger $T -ScheduledJobOption $O

