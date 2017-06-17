Using module '..\TweekModule.psm1'

class DiagTrack : TweekModule {
  [string[]] $PolicyReferences = @(
    'http://www.forbes.com/sites/gordonkelly/2015/11/24/windows-10-automatic-spying-begins-again/#5f0b888d2d97'
  )
  [string] $Description = (
    'Disables user data collection/tracking and reporting to microsoft.'
  )
  [string] $LongDescription = (
    'This service (DiagTrack: Connected User Experience and Telemetry) ' +
    'collects user and usage data on the machine, and reports it back to ' +
    'microsoft. There is no benefit to the user running this service.'
  )
  [string] $ManualDescription = (
    "*  win + r > services.msc`n" +
    "   *  Select 'Connected User Experiences and Telemetry (DiagTrack)'`n" +
    "      *  right-click > stop`n" +
    "      *  right-click > properties > disable`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::telemetry

  hidden [void] ServiceTweek() {
    $this.Service.Disable('DiagTrack')
  }
}

function Load() {
  return [DiagTrack]::New()
}

Export-ModuleMember -Function Load