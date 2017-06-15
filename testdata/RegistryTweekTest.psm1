# test module for registry workings
#
# uses tests registry locations.

Using module '..\TweekModule.psm1'

class RegistryTweekTest : TweekModule {
  [WindowsEdition[]] $EditionList = @(
    [WindowsEdition]::Microsoft_Windows_10_Pro
  )
  [string[]] $PolicyReferences = @('https://some.shit')
  [string] $Description = 'Tests registry tweaks.'
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKCU:\Software\TweekTest\Scripts\Others', 'Version', 'DWORD', 1)
    $this.Registry.UpdateKey('HKCU:\Software\TweekTest\Scripts', 'Test', 'STRING', 'testing string')
    $this.Registry.DeleteKey('HKCU:\Software\TweekTest\Scripts\Others', 'Version')
    $this.Registry.EnumerateKey('HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps')
  }

  hidden [void] ExecuteOrDryRun() { $this.ApplyTweak() }
}

function Load() {
  return [RegistryTweekTest]::New()
}

Export-ModuleMember -Function Load