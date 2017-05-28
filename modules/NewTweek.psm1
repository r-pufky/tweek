# test module import and inheritence

using module '..\TweekModule.psm1'

class NewTweek : TweekModule {
  [WindowsEdition] $edition = [WindowsEdition]::pro
  [string[]] $policy_references = @('https://some.shit',
                                    'https://some.other.shit')
  [string] $description = 'This a new tweak that does things.'
  [TweakClassification] $classification = [TweakClassification]::optional
  [TweakCatagory] $catagory = [TweakCatagory]::hardware
}

function Load() {
  return [NewTweek]::New()
}

Export-ModuleMember -Function Load