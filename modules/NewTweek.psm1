# test module import and inheritence

Using module '..\TweekModule.psm1'

class NewTweek : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::pro
  [string[]] $PolicyReferences = @('https://some.shit',
                                   'https://some.other.shit')
  [string] $Description = 'This a new tweak that does things.'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware
}

function Load() {
  return [NewTweek]::New()
}

Export-ModuleMember -Function Load