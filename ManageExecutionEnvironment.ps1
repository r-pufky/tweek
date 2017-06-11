# Manage permissions for script to run. We determine the system permissions
# before running, execute and then reset permissions to the original settings.
#
# Powershell modules need to be unblocked so they can be imported if they are
# not signed by a CA and trusted from your cert store. This tool runs with the
# ExecutionPolicy set to 'Unrestricted'.
#
# This is not setup as a module so it can be used with needing to Unblock it
# first.
#
# See setting Execution Policy:
#   - https://technet.microsoft.com/en-us/library/ee176961.aspx
#

class ManageExecutionEnvironment {
  [string] $OriginalPolicy

  [void] SetPolicy() {
    # Sets Execution policies required for tweek to work.
    #
    Write-Host 'Ensuring permissions are set properly ...'
    $this.OriginalPolicy = (Get-ExecutionPolicy)
    if ($this.OriginalPolicy -ne 'Unrestricted') {
      Write-Warning 'Set ExecutionPolicy to: Unrestricted'
      Set-ExecutionPolicy 'Unrestricted' -Force
    }
  }

  [void] RestorePolicy() {
    # Restores previous system policy when exiting tweek.
    #
    Write-Warning ("`n`nRestoring ExectionPolicy to: " + $this.OriginalPolicy)
    Set-ExecutionPolicy $this.OriginalPolicy -Force
  }

  [void] UnblockModules($VerbosePreference) {
    # Unblock modules for tweek to import.
    #
    # Args:
    #   VerbosePreference: Object containing verbosity option.
    #
    if ($VerbosePreference -ne 'Continue') {
      Get-ChildItem -Recurse -Filter *.psm1 | Unblock-File
    } else {
      Get-ChildItem -Recurse -Filter *.psm1 | Unblock-File -Verbose
    }
  }

  [void] MountRegistryDrives() {
    # Mount registry hives with shortcuts for easy of use in tweek modules
    #
    Write-Verbose 'Mounting registry drives for use ...'
    Write-Verbose (New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS)
    Write-Verbose (New-PSDrive -Name HKCR -PSProvider Registry -Root Registry::HKEY_CLASSES_ROOT)
    Write-Verbose (New-PSDrive -Name HKCC -PSProvider Registry -Root Registry::HKEY_CURRENT_CONFIG)
    Write-Verbose (New-PSDrive -Name HKCU -PSProvider Registry -Root Registry::HKEY_CURRENT_USER)
    Write-Verbose (New-PSDrive -Name HKLM -PSProvider Registry -Root Registry::HKEY_LOCAL_MACHINE)
  }

  [Array] GetWindowsVersion() {
    # Returns the current Windows 10 release information from the environment.
    #
    # Returns:
    #   Array containing ([String] Edition, [Integer] Version).
    #
    $Edition = Get-WmiObject -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption
    $Version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    Write-Verbose ('Edition: ' + $Edition + '; Version: ' + $Version)
    return @($Edition, [int]$Version)
  }
}
