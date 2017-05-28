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
  [string] $original_policy

  [void] SetPolicy() {
    Write-Output 'Ensuring permissions are set properly ...'
    $this.original_policy = (Get-ExecutionPolicy)
    if ($this.original_policy -ne 'Unrestricted') {
      Write-Output 'Set ExecutionPolicy to Unrestricted'
      Set-ExecutionPolicy 'Unrestricted' -Force
    }
  }

  [void] RestorePolicy() {
    Write-Output 'Restoring ExectionPolicy to: ' + $this.original_policy
    Set-ExecutionPolicy $this.original_policy -Force
  }

  [void] UnblockModules() {
    Get-ChildItem -Recurse -Filter *.psm1 | Unblock-File -Verbose
  }
}
