# Provides interface to Windows Services for Tweek Modules.
#

class TweekServiceInterface {
  [string[]]$AcceptedValues = @('BOOT', 'SYSTEM', 'AUTOMATIC', 'MANUAL', 'DISABLED')
  $_VerbosePreference

  [void] DisableService([string]$Name) {
    # Disables and stops a given service.
    #
    # Args:
    #   Name: String service name to disable.
    #
    # Raises:
    #   System.ArgumentOutOfRangeException if the specified service does not
    #   exist.
    #
    if (!(Get-Service -Name $Name -ErrorAction SilentlyContinue)) {
      throw [System.ArgumentOutOfRangeException]::New('DisableService requires a valid service name [' + $Name + '] is not a valid service.')
    }
    Write-Host ('    Stopping and Disabling Service: ' + $Name)
    Set-Service $Name -StartupType Disabled
    Stop-Service $Name
  }

  [void] EnableService([string]$Name) {
    # Enables and starts a given service.
    #
    # The service is set to start automatically.
    #
    # Args:
    #   Name: String service name to enable.
    #
    # Raises:
    #   System.ArgumentOutOfRangeException if the specified service does not
    #   exist.
    #
    if (!(Get-Service -Name $Name -ErrorAction SilentlyContinue)) {
      throw [System.ArgumentOutOfRangeException]::New('EnableService requires a valid service name [' + $Name + '] is not a valid service.')
    }
    Write-Host ('    Starting and Enabling Service: ' + $Name)
    Set-Service $Name -StartupType Automatic
    Start-Service $Name
  }
}
