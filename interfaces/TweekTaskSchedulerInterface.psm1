# Provides interface to Windows Task Scheduler for Tweek Modules.
#
# All scheduled tasks can be found with Get-ScheduledTask
#
# Because of a bug with handling scheduled tasks with spaces in the name of the
# task (causes (Enable|Disable)-ScheduledTask to fail with invalid argument
# when using a variable), we search for that task and pipe it to the respective
# command.
#
# https://github.com/PowerShell/PowerShell/issues/3915
#

class TweekTaskSchedulerInterface {
  $_VerbosePreference

  [void] Disable([string]$Name) {
    # Disables a given scheduled task.
    #
    # Args:
    #   Name: String task name to disable.
    #
    # Raises:
    #   System.ArgumentOutOfRangeException if the specified task does not
    #   exist.
    #
    if (!(Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue)) {
      throw [System.ArgumentOutOfRangeException]::New('DisableTask requires a valid task name [' + $Name + '] is not a valid task.')
    }
    Write-Host ('    Disabling scheduled task: ' + $Name)
    # Work around for name spacing bug using variable and disable-task
    Get-ScheduledTask | where-object {($_.TaskName -eq $Name)} | Disable-ScheduledTask
  }

  [void] Enable([string]$Name) {
    # Enables a given scheduled task.
    #
    # Args:
    #   Name: String task name to enable.
    #
    # Raises:
    #   System.ArgumentOutOfRangeException if the specified task does not
    #   exist.
    #
    if (!(Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue)) {
      throw [System.ArgumentOutOfRangeException]::New('EnableTask requires a valid task name [' + $Name + '] is not a valid task.')
    }
    Write-Host ('    Starting scheduled task: ' + $Name)
    # Work around for name spacing bug using variable and enable-task
    Get-ScheduledTask | where-object {($_.TaskName -eq $Name)} | Enable-ScheduledTask

  }
}
