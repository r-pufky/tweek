# test module import and inheritence

using module '..\base\tweak.psm1'

class NewTweek : TweakModule {
  [WindowsEdition] $edition = [WindowsEdition]::pro
}

function Load() {
  return [NewTweek]::New()
}

Export-ModuleMember -Function Load