param(
[switch]$uninstall = $false,
[switch]$reload = $false
)
#Add your websites in the spaces below the @'
#MUST BE LITERAL - NO '*.website.com' Matches
$opDir = $PSCommandPath
$websites = gc "$(Split-Path -Parent $opDir)\sites.txt"
#if -uninstall param is used, removes task, deletes VB script, and turns off DNS logging
if($uninstall){
    Unregister-ScheduledTask -TaskName OBSKill -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item C:\Users\Public\OBSKill.vbs -Force -ErrorAction SilentlyContinue
    $logName = 'Microsoft-Windows-DNS-Client/Operational'
    $log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
    $log.IsEnabled=$false
    $log.SaveChanges()
    exit
}

$webQueries = ""
#builds the or statements for the DNS queries
for($i = 0; $i -lt $websites.Length; $i++){
    #Dont add an or for the last entry
    if($i -eq ($websites.Length - 1)){
        $webQueries += "Data=`'$($websites[$i])`'"
    }else{
        $webQueries += "Data=`'$($websites[$i])`' or "
    }
}

$killerTask= @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2019-07-01T20:55:53.5784045</Date>
    <Author>Smitty</Author>
    <URI>\OBSKill</URI>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-DNS-Client/Operational"&gt;&lt;Select Path="Microsoft-Windows-DNS-Client/Operational"&gt;
*[EventData[Data[@Name ='QueryName'] and ($($webQueries))]] 
&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Users\Public\OBSKill.vbs</Command>
    </Exec>
  </Actions>
</Task>
"@

if($reload){
    Unregister-ScheduledTask -TaskName OBSKill -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    Register-ScheduledTask -xml $killerTask -User $("$env:computername\$env:USERNAME") -TaskName "OBSKill" –Force | Out-Null
    exit
}

$killerString = @'
Dim objShell
Set objShell=CreateObject("WScript.Shell")
strExpression="Get-Process obs* | stop-process"
strCMD="powershell -sta -noProfile -NonInteractive  -nologo -command " & Chr(34) &_
"&{" & strExpression &"}" & Chr(34) 
objShell.Run strCMD,0
'@

#enables DNS logging
$logName = 'Microsoft-Windows-DNS-Client/Operational'
$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
$log.IsEnabled=$true
$log.SaveChanges()

Register-ScheduledTask -xml $killerTask -User $("$env:computername\$env:USERNAME") -TaskName "OBSKill" –Force | Out-Null
$killerString | Out-File C:\Users\Public\OBSKill.vbs