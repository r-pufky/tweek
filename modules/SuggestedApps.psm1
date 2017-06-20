Using module '..\TweekModule.psm1'

class SuggestedApps : TweekModule {
  [string[]] $PolicyReferences = @(
    'https://www.howtogeek.com/259946/how-to-get-rid-of-suggested-apps-in-windows-10/'
  )
  [string] $Description = (
    'Disable suggested applications for Windows 10.'
  )
  [string] $LongDescription = (
    'Windows 10 will automatically download and suggest apps based on ' +
    'popularity and you habits. These will appear in your start menu even ' +
    'though you never explicitly installed them. This tweak disables the ' +
    'suggesting and installation of these apps.'
  )
  [string] $ManualDescription = (
    "*  win + r > regedit`n" +
    '   *  Key: KHEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\' +
    "CloudContent`n" +
    "      *  DWORD: DisableWindowsConsumerFeatures = 1`n" +
    "   *  Key: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\" +
    "ContentDeliveryManager\SuggestedApps`n" +
    "      *  DWORD: (all suggested apps listed) = 0" +
    "*  win + r > gpedit.msc`n" +
    '   *  Key: Computer Configuration > Administrative Templates > ' +
    "Windows Components > Cloud Content`n" +
    "      *  Policy: Turn off Microsoft consumer experiences = Enabled`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::store

  hidden [void] GroupPolicyTweek() {
    $this.GroupPolicy.Update('Machine', 'SOFTWARE\Policies\Microsoft\Windows\CloudContent', 'DisableWindowsConsumerFeatures', 'DWORD', 1)
  }

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent', 'DisableWindowsConsumerFeatures', 'DWORD', 1)
    $SuggestedApps = $this.Registry.EnumerateKey('HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps')
    foreach ($App in $SuggestedApps.GetEnumerator()) {
      $this.Registry.UpdateKey('HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps', $App.Name, $App.Value[0], 0)
    }
  }
}

function Load() {
  return [SuggestedApps]::New()
}

Export-ModuleMember -Function Load