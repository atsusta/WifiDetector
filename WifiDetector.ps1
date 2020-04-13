Add-Type -AssemblyName System.Windows.Forms

Function Invoke-BalloonTip {
  <#
  .Synopsis
    Display a balloon tip message in the system tray.
  .Description
    This function displays a user-defined message as a balloon popup in the system tray. This function
    requires Windows Vista or later.
  .Parameter Message
    The message text you want to display.  Recommended to keep it short and simple.
  .Parameter Title
    The title for the message balloon.
  .Parameter MessageType
    The type of message. This value determines what type of icon to display. Valid values are
  .Parameter SysTrayIcon
    The path to a file that you will use as the system tray icon. Default is the PowerShell ISE icon.
  .Parameter Duration
    The number of seconds to display the balloon popup. The default is 1000.
  .Inputs
    None
  .Outputs
    None
  .Notes
    NAME:      Invoke-BalloonTip
    VERSION:   1.0
    AUTHOR:    Boe Prox
    URL:       https://mcpmag.com/articles/2017/09/07/creating-a-balloon-tip-notification-using-powershell.aspx
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$True,HelpMessage="The message text to display. Keep it short and simple.")]
    [string]$Message,

    [Parameter(HelpMessage="The message title")]
     [string]$Title="Attention $env:username",

    [Parameter(HelpMessage="The message type: Info,Error,Warning,None")]
    [System.Windows.Forms.ToolTipIcon]$MessageType="Info",

    [Parameter(HelpMessage="The path to a file to use its icon in the system tray")]
    [string]$SysTrayIconPath='C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',

    [Parameter(HelpMessage="The number of milliseconds to display the message.")]
    [int]$Duration=1000
  )

  Add-Type -AssemblyName System.Windows.Forms

  If (-NOT $global:balloon) {
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon

    # Dispose
    [void](Register-ObjectEvent -InputObject $balloon -EventName BalloonTipClosed -SourceIdentifier IconClicked -Action {
      #Perform cleanup actions on balloon tip
      Write-Verbose 'Disposing of balloon'
      $global:balloon.dispose()
      Unregister-Event -SourceIdentifier IconClicked
      Remove-Job -Name IconClicked
      Remove-Variable -Name balloon -Scope Global
    })
  }

  #Need an icon for the tray
  $path = Get-Process -id $pid | Select-Object -ExpandProperty Path

  #Extract the icon from the file
  $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($SysTrayIconPath)

  #Can only use certain TipIcons: [System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property
  $balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]$MessageType
  $balloon.BalloonTipText  = $Message
  $balloon.BalloonTipTitle = $Title
  $balloon.Visible = $true

  #Display the tip and specify in milliseconds on how long balloon will stay visible
  $balloon.ShowBalloonTip($Duration)

  Write-Verbose "Ending function"

}

# Events
# Microsoft-Windows-WLAN-AutoConfig/Operational
# Microsoft-Windows-NetworkProfile/Operational
$event = Get-WinEvent -LogName "Microsoft-Windows-NetworkProfile/Operational" -MaxEvents 1

# Event IDs
#   Microsoft-Windows-NetworkProfile/Operational
#     10000: 네트워크 연결됨...
#     10001: 네트워크 연결 끊김...
#   Microsoft-Windows-WLAN-AutoConfig/Operational
#     8001: WLAN AutoConfig 서비스가 무선 네트워크에 연결되었습니다....
#     8003: WLAN AutoConfig 서비스가 무선 네트워크에서 연결이 끊어졌습니다....
#     11004: 무선 보안이 중지되었습니다....
Switch ($event.Id)
{
  10001 {
    Invoke-BalloonTip -Message "......" -Title "네트워크가 죽었습니다" -MessageType "Warning" -Duration 5000
    break
  }
  10000 {
    Invoke-BalloonTip -Message "......" -Title "네트워크가 열렸습니다" -MessageType "Info" -Duration 3000
    break
  }
}
