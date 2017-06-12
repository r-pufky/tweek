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
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::services

  hidden [void] ServiceTweek() {
    $this.ScheduledTask.DisableTask('Data Integrity Scan for Crash Recovery')
    $this.ScheduledTask.EnableTask('Data Integrity Scan for Crash Recovery')
  }

  hidden [void] ExecuteOrDryRun([switch]$DryRun, [switch]$Testing) { $this.ApplyTweak() }
}

function Load() {
  return [ScheduledTaskTest]::New()
}

Export-ModuleMember -Function Load