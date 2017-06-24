Using module '..\TweekModule.psm1'

class ScheduledReFSScrub : TweekModule {
  [string[]] $PolicyReferences = @(
    'http://bakins-bits.com/wordpress/?p=195',
    'https://www.reddit.com/r/Windows10/comments/61dtk3/fix_100_disk_usage_refs_filesystems/'
  )
  [string] $Description = (
    'Disables ReFS disk scrubs on boot/crash recovery'
  )
  [string] $LongDescription = (
    'ReFS will scrub disks (ensure data integrity) on boot after an unclean' +
    'unmount or a crash. This scrubbing typically will peg the CPU at 100% ' +
    "usage until all data has been checked.`n`n" +
    'This will *disable* scheduled tasks to scrub ReFS. This is ' +
    '**DATA DANGERGOUS** and you should **MANUALLY** scrub your disks if you ' +
    'choose to enable this tweek.'
  )
  [string] $ManualDescription = (
    "*  start > Task Scheduler`n" +
    '   *  Task Scheduler Library > Microsoft > Windows > ' +
    "Data Integrity Scan`n" +
    "      *  Key: Data Integrity Scan = Disabled`n" +
    "      *  Key: Data Integrity Scan for Crash Recovery = Disabled"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::filesystem

  hidden [void] ServiceTweek() {
    $this.ScheduledTask.Disable('Data Integrity Scan')
    $this.ScheduledTask.Disable('Data Integrity Scan for Crash Recovery')
  }
}

function Load() {
  return [ScheduledReFSScrub]::New()
}

Export-ModuleMember -Function Load