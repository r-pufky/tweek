Using module '..\TweekModule.psm1'

class WindowsDefender : TweekModule {
  [string[]] $PolicyReferences = @(
    'https://www.tenforums.com/tutorials/5918-turn-off-windows-defender-windows-10-a.html'
  )
  [string] $Description = (
    'Disable Windows Defender.'
  )
  [string] $LongDescription = (
    'Windows Defender Antivirus helps protect your PC against malware ' +
    '(malicious software) like viruses, spyware, and other potentially ' +
    'unwanted software. Malware can infect your PC without your knowledge: ' +
    'it might install itself from an email message, when you connect to the ' +
    'Internet, or when you install certain apps using a USB flash drive, ' +
    'CD, DVD, or other removable media. Some malware can also be programmed ' +
    "to run at unexpected times, not only when it's installed.`n`n" +
    'Windows Defender is included with Windows and helps keep malware from ' +
    "infecting your PC in two ways:`n" +
    '*  Providing real-time protection. Windows Defender notifies you when ' +
    'malware tries to install itself or run on your PC. It also notifies ' +
    "you when apps try to change important settings.`n" +
    '*  Providing anytime scanning options. Windows Defender automatically ' +
    'scans your PC for installed malware on a regular basis, but you can ' +
    'also start a scan whenever you want. Windows Defender automatically ' +
    "removes (or temporarily quarantines) anything that's detected during " +
    "a scan.`n`nDO NOT DISABLE THIS UNLESS YOU KNOW WHAT YOU ARE DOING."
  )
  [string] $ManualDescription = (
    "*  win + r > regedit`n" +
    '   *  Key: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\' +
    "Windows Defender`n" +
    "      *  DWORD: DisableAntiSpyware = 1`n" +
    '   *  Key: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\' +
    "Windows Defender\Real-time Protection`n" +
    "      *  DWORD: DisableRealtimeMonitoring = 1`n" +
    '   *  Key: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\' +
    "Windows Defender\Reporting`n" +
    "      *  DWORD: DisableEnhancedNotifications = 1`n" +
    '   *  Key: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\' +
    "Windows Defender\UX Configuration`n" +
    "      *  DWORD: Notification_Suppress = 1`n" +
    "*  win + r > gpedit.msc`n" +
    '   *  Key: Computer Configuration > Administrative Templates > ' +
    "Windows Components > Windows Defender Antivirus`n" +
    "      *  Policy: Turn off Windows Defender Antivirus = Enabled`n" +
    '   *  Key: Computer Configuration > Administrative Templates > ' +
    'Windows Components > Windows Defender Antivirus > ' +
    "Real-time Protection`n" +
    "      *  Policy: Turn off real-time Protection = Enabled`n" +
    '   *  Key: Computer Configuration > Administrative Templates > ' +
    "Windows Components > Windows Defender Antivirus > Reporting`n" +
    "      *  Policy: Turn off Enhanced Notifications = Enabled`n" +
    '   *  Key: Computer Configuration > Administrative Templates > ' +
    "Windows Components > Windows Defender Antivirus > Client Interface`n" +
    "      *  Policy: Suppress all Notifications = Enabled`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::system

  hidden [void] GroupPolicyTweek() {
    $this.GroupPolicy.Update('Machine', 'SOFTWARE\Policies\Microsoft\Windows Defender', 'DisableAntiSpyware', 'DWORD', 1)
    $this.GroupPolicy.Update('Machine', 'SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection', 'DisableRealtimeMonitoring', 'DWORD', 1)
    $this.GroupPolicy.Update('Machine', 'SOFTWARE\Policies\Microsoft\Windows Defender\Reporting', 'DisableEnhancedNotifications', 'DWORD', 1)
    $this.GroupPolicy.Update('Machine', 'SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration', 'Notification_Suppress', 'DWORD', 1)
  }

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender', 'DisableAntiSpyware', 'DWORD', 1)
    $this.Registry.UpdateKey('HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection', 'DisableRealtimeMonitoring', 'DWORD', 1)
    $this.Registry.UpdateKey('HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting', 'DisableEnhancedNotifications', 'DWORD', 1)
    $this.Registry.UpdateKey('HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration', 'Notification_Suppress', 'DWORD', 1)
  }
}

function Load() {
  return [WindowsDefender]::New()
}

Export-ModuleMember -Function Load