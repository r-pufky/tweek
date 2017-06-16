Using module '..\TweekModule.psm1'

class SilentAppInstalls : TweekModule {
  [string[]] $PolicyReferences = @(
    'https://www.youtube.com/watch?v=wgKJMsJ-6XU&feature=youtu.be&t=4m47s'
  )
  [string] $Description = (
    'Disable silent automatic installation of apps.'
  )
  [string] $LongDescription = (
    'Windows 10 will automatically download and install suggested apps, ' +
    'which is both annoying and violates user trust. The list of ' +
    'applications is updated frequently, including every major version ' +
    'release. This will disable the silent installation of suggested apps ' +
    'and remove currently suggested apps.'
  )
  [string] $ManualDescription = (
    "*  win + r > regedit`n" +
    "   *  Key: HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\" +
    "ContentDeliveryManager`n" +
    "      *  DWORD: SilentInstalledAppsEnabled = 0`n" +
    "   *  Key: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\" +
    "ContentDeliveryManager\SuggestedApps`n" +
    "      *  DWORD: (all suggested apps listed) = 0"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::store

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager', 'SilentInstalledAppsEnabled', 'DWORD', 0)
    $SuggestedApps = $this.Registry.EnumerateKey('HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps')
    foreach ($App in $SuggestedApps.GetEnumerator()) {
      $this.Registry.UpdateKey('HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps', $App.Name, $App.Value[0], 0)
    }
  }
}

function Load() {
  return [SilentAppInstalls]::New()
}

Export-ModuleMember -Function Load