﻿Using module '..\TweekModule.psm1'

class RazerSynapse : TweekModule {
  [string[]] $PolicyReferences = @(
    'http://blog.ultimateoutsider.com/2016/02/razers-terrible-game-scanner-service.html'
  )
  [string] $Description = (
    'Disables extra razer synapse services.'
  )
  [string] $LongDescription = (
    'Razer synapse by default will install a game scanning service that ' +
    "scans your drive for installed games. There's no benefit to this, as " +
    'multiple other gaming platforms and drivers already scan your games.'
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware

  hidden [void] ServiceTweek() {
    $this.ServiceInterface.DisableService('Razer Game Scanner Service')
  }
}

function Load() {
  return [RazerSynapse]::New()
}

Export-ModuleMember -Function Load