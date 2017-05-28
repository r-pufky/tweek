# test module import and inheritence

using module '..\TweekModule.psm1'

class NewTweek : TweekModule {
  [WindowsEdition] $edition = [WindowsEdition]::pro
}

function Load() {
  return [NewTweek]::New()
}

Export-ModuleMember -Function Load