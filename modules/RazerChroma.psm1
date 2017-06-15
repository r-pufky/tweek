Using module '..\TweekModule.psm1'

class RazerChroma : TweekModule {
  [string[]] $PolicyReferences = @(
    'http://developer.razerzone.com/works-with-chroma/'
  )
  [string] $Description = (
    'Disables razer Chroma (lighting effects) services.'
  )
  [string] $LongDescription = (
    'Razer Chroma is a SDK framework to control LED lighting on your razer ' +
    'devices; it also does application integration and allows games to ' +
    'control your color scheme while playing.'
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::hardware

  hidden [void] ServiceTweek() {
    $this.Service.Disable('Razer Chroma SDK Server')
    $this.Service.Disable('Razer Chroma SDK Service')
  }
}

function Load() {
  return [RazerChroma]::New()
}

Export-ModuleMember -Function Load