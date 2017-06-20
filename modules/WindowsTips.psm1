Using module '..\TweekModule.psm1'

class WindowsTips : TweekModule {
  [string[]] $PolicyReferences = @(
    'https://www.tenforums.com/tutorials/30869-turn-off-tip-trick-suggestion-notifications-windows-10-a.html',
    'https://community.spiceworks.com/how_to/140172-disable-windows-tips-on-windows-10-through-group-policy'
  )
  [string] $Description = (
    'Disable Tips, Tricks and Suggestion Notifications.'
  )
  [string] $LongDescription = (
    'By default, Windows 10 will occasionally show you notifications for ' +
    'helpful tips about using Windows 10. While some tips can be helpful, ' +
    'some suggestions may include advertising. You may not wish to see ' +
    'these notifications anymore. Some people have also reported that they ' +
    'have sometimes experienced high CPU and memory usage caused by these ' +
    'tips notifications.'
  )
  [string] $ManualDescription = (
    "*  win + r > regedit`n" +
    '   *  Key: HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\' +
    "ContentDeliveryManager`n" +
    "      *  DWORD: SoftLandingEnabled = 0`n" +
    "*  win + r > gpedit.msc`n" +
    '   *  Key: Computer Configuration > Administrative Templates > ' +
    "Windows Components > Cloud Content`n" +
    "      *  Policy: Do not show Windows Tips = Enabled`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::store

  hidden [void] GroupPolicyTweek() {
    $this.GroupPolicy.Update('Machine', 'SOFTWARE\Policies\Microsoft\Windows\CloudContent', 'DisableSoftLanding', 'DWORD', 1)
  }

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager', 'SoftLandingEnabled', 'DWORD', 0)
  }
}

function Load() {
  return [WindowsTips]::New()
}

Export-ModuleMember -Function Load