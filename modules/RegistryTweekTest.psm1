﻿# test module for registry workings
#
# uses tests registry locations.

Using module '..\TweekModule.psm1'

class RegistryTweekTest : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::pro
  [string[]] $PolicyReferences = @('https://some.shit')
  [string] $Description = 'Tests registry tweaks.'
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateRegistryKey('HKCU:\Software\TweekTest\Scripts\Others', 'Version', 'DWORD', 1)
    $this.Registry.UpdateRegistryKey('HKCU:\Software\TweekTest\Scripts', 'Test', 'STRING', 'testing string')
    $this.Registry.DeleteRegistryKey('HKCU:\Software\TweekTest\Scripts\Others', 'Version')
  }
}

function Load() {
  return [RegistryTweekTest]::New()
}

Export-ModuleMember -Function Load