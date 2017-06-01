# test module import and inheritence

using module '..\TweekModule.psm1'

class NewTweek : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::pro
  [string[]] $PolicyReferences = @('https://some.shit',
                                   'https://some.other.shit')
  [string] $Description = 'This a new tweak that does things.'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware

  hidden [void] GroupPolicyTweek() {}
  hidden [void] RegistryTweek() {}

}

function Load() {
  return [NewTweek]::New()
}

Export-ModuleMember -Function Load