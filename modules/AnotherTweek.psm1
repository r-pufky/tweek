# test module import and inheritence

Using module '..\TweekModule.psm1'

class AnotherTweek : TweekModule {
  [WindowsEdition[]] $EditionList = @(
      [WindowsEdition]::Microsoft_Windows_10_Home,
      [WindowsEdition]::Microsoft_Windows_10_Pro
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [string] $Description = 'Another tweek to test'
  [string[]] $PolicyReferences = @('http://github.com/r-pufky/tweek')
}

function Load() {
  return [AnotherTweek]::New()
}

Export-ModuleMember -Function Load