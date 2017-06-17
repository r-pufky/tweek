Using module '..\TweekModule.psm1'

class OneDrive : TweekModule {
  [string[]] $PolicyReferences = @(
    'https://support.office.com/en-us/article/Turn-off-or-uninstall-OneDrive-f32a17ce-3336-40fe-9c38-6efb09f944b0'
  )
  [string] $Description = (
    'Disables Microsoft OneDrive.'
  )
  [string] $LongDescription = (
    'By default Microsoft now installs OneDrive on Windows 10 installs. ' +
    'OneDrive creates a taskbar icon, and runs in the background, as well ' +
    'as syncing files to Microsoft Cloud.'
  )
  [string] $ManualDescription = (
    "*  win + r > gpedit.msc`n" +
    "   *  Key: Computer Configuration > Administrative Templates > " +
    "Windows Components > OneDrive`n" +
    "   *  Policy: Prevent the usage of OneDrive for file storage = " +
    "Enabled`n" +
    "*  start > Task Scheduler > Task Scheduler Library`n" +
    "   *  Key: OneDrive Standalone Update Task v2 = Disabled`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::services

  hidden [void] GroupPolicyTweek() {
    $this.GroupPolicy.Update('Machine', 'Software\Policies\Microsoft\Windows\OneDrive', 'DisableFileSyncNGSC', 'DWORD', 1)
  }

  hidden [void] ScheduledTaskTweek() {
    $this.ScheduledTask.Disable('OneDrive Standalone Update Task v2')
  }
}

function Load() {
  return [OneDrive]::New()
}

Export-ModuleMember -Function Load