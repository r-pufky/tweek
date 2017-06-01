# test module import and inheritence

using module '..\TweekModule.psm1'

class AnotherTweek : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::home
  [string] $Author = 'github.com/r-pufky/tweek'
  [string] $Description = 'Another tweek to test'
  [string[]] $PolicyReferences = @('http://github.com/r-pufky/tweek')

  hidden [void] GroupPolicyTweek() {}
  hidden [void] RegistryTweek() {}
}

function Load() {
  return [AnotherTweek]::New()
}

Export-ModuleMember -Function Load