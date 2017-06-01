# test module for group policy workings
#
# uses tests group policy locations.

Using module '..\TweekModule.psm1'

class GroupPolicyTweekTest : TweekModule {

  [WindowsEdition] $Edition = [WindowsEdition]::pro
  [string[]] $PolicyReferences = @('https://some.shit')
  [string] $Description = 'Tests group policy tweaks.'
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware

  hidden [void] GroupPolicyTweek() {
    $this.GroupPolicy.UpdateGroupPolicy('Machine', 'Software\Policies\Microsoft\Windows\GameDVR', 'AllowGameDVR', 'DWORD', 0)
    $this.GroupPolicy.DeleteGroupPolicy('Machine', 'Software\Policies\Microsoft\Windows\GameDVR', 'AllowGameDVR')
  }
}

function Load() {
  return [GroupPolicyTweekTest]::New()
}

Export-ModuleMember -Function Load