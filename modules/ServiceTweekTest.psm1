# test module for service workings
#
# uses tests service locations (BITS).

using module '..\TweekModule.psm1'

class ServiceTweekTest : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::pro
  [string[]] $PolicyReferences = @('github.com/r-pufky/tweek')
  [string] $Description = 'Tests service tweaks.'
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::services

  hidden [void] GroupPolicyTweek() {}

  hidden [void] RegistryTweek() {}

  hidden [void] ServiceTweek() {
    $this.ServiceInterface.DisableService('BITS')
    $this.ServiceInterface.EnableService('BITS')
  }
}

function Load() {
  return [ServiceTweekTest]::New()
}

Export-ModuleMember -Function Load