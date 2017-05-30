# test module for group policy workings
#
# uses tests group policy locations.

using module '..\TweekModule.psm1'

class GroupPolicyTweekTest : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::pro
  [string[]] $PolicyReferences = @('https://some.shit')
  [string] $Description = 'Tests group policy tweaks.'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware

  [void] _GroupPolicyTweak() {
    $this._UpdateGroupPolicy('Software\Policies\Microsoft\Windows\GameDVR', 'AllowGameDVR', 'DWORD', 0)
    $this._DeleteGroupPolicy('Software\Policies\Microsoft\Windows\GameDVR', 'AllowGameDVR')
  }
}

function Load() {
  return [GroupPolicyTweekTest]::New()
}

Export-ModuleMember -Function Load