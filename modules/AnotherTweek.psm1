# test module import and inheritence

using module '..\TweekModule.psm1'

class AnotherTweek : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::home

  hidden [void] GroupPolicyTweek() {}
  hidden [void] RegistryTweek() {}
}

function Load() {
  return [AnotherTweek]::New()
}

Export-ModuleMember -Function Load