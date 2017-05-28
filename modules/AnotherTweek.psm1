# test module import and inheritence

using module '..\TweekModule.psm1'

class AnotherTweek : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::home
}

function Load() {
  return [AnotherTweek]::New()
}

Export-ModuleMember -Function Load