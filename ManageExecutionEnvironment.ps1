﻿# Manage permissions for script to run. We determine the system permissions
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
      Write-Host 'Set ExecutionPolicy to Unrestricted'
      Set-ExecutionPolicy 'Unrestricted' -Force
    }
  }

  [void] RestorePolicy() {
    # Restores previous system policy when exiting tweek.
    #
    Write-Host ("`nRestoring ExectionPolicy to: " + $this.OriginalPolicy)
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
}
