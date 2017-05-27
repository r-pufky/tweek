# test module import and inheritence

using module '..\base\tweak.psm1'

class AnotherTweek : TweakModule {
  [WindowsEdition] $edition = [WindowsEdition]::home
}

function Load() {
  return [AnotherTweek]::New()
}

Export-ModuleMember -Function Load