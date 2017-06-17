# test module for scheduled tasks workings
#
# uses tests scheduled tasks (Data Integrity Scan for Crash Recovery).

Using module '..\TweekModule.psm1'

class ScheduledTaskTest : TweekModule {
  [WindowsEdition[]] $EditionList = @(
    [WindowsEdition]::Microsoft_Windows_10_Pro
  )
  [string[]] $PolicyReferences = @('github.com/r-pufky/tweek')
  [string] $Description = 'Tests scheduled task tweaks.'
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::services

  hidden [void] ServiceTweek() {
    $this.ScheduledTask.Disable('Data Integrity Scan for Crash Recovery')
    $this.ScheduledTask.Enable('Data Integrity Scan for Crash Recovery')
  }

  hidden [void] ExecuteOrDryRun() { $this.ApplyTweak() }
}

function Load() {
  return [ScheduledTaskTest]::New()
}

Export-ModuleMember -Function Load