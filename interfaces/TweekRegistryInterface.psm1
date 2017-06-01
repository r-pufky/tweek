﻿# Provides interface to Windows Group Policy for Tweek Modules.
#
# This class assumes that the registry hive shortcuts have already been mapped
# with PSDrive, which is done as a one-time setup in
# ManageExecutionEnvironment.
#
# Startup Items (These are not regsitry only!):
# 1) Show all startup items for the current user (powershell):
# 
#   Get-CimInstance Win32_StartupCommand | select-object * | format-list
#
# 2) Location will point to the registry location, local file location or 'common startup'
# 3) If one of those, make tweek for registry or local file
# 4) If 'common startup' it will reside in:
#    C:\Users\Username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
#    C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
#    http://www.thewindowsclub.com/startup-folder-in-windows-8
#

class TweekRegistryInterface {
  [string[]]$AcceptedValues = @('STRING', 'EXPANDSTRING', 'BINARY', 'DWORD', 'MULTISTRING', 'QWORD', 'UNKNOWN')

  [void] UpdateRegistryKey([string]$Path, [string]$Key, [string]$Type, $Value) {
    # Modifies or creates a given registry key with a value.
    #
    # This will:
    # - recursively create path directories as needed.
    # - properly create new values when none existed.
    # - properly overwrite an existing value.
    # - properly creates new subdirectories properly, non-destructively.
    #
    # Registry key breakdown:
    # regedit: Computer\HKEY_CURRENT_USER\Software\Microsoft\OneDrive\OptinFolderRedirect = 0
    #   Path: HKCU:\Software\Microsoft\OneDrive
    #   Key: OptinFolderRedirect
    #   Type: DWORD
    #   Value: 0
    #
    # Registry key shortcuts:
    #    HKLM: HKEY_LOCAL_MACHINE
    #    HKCR: HKEY_CLASSES_ROOT
    #    HKCU: HKEY_CURRENT_USER
    #    HKCC: HKEY_CURRENT_CONFIG
    #    HKU: HKEY_USERS
    #
    # Args:
    #   Path: String registry path. Shortcut usage is ok.
    #   Key: String registry key name.
    #   Type: String registry key type. Valid types:
    #       STRING, EXPANDSTRING, BINARY, DWORD, MULTISTRING, QWORD, UNKNOWN
    #       (reg_sz, reg_expand_sz, reg_binary, reg_dword, reg_multi_sz, reg_qword, reg_resource_list)
    #   Value: Data to load into the key.
    #
    # Raises:
    #   System.ArgumenOutOfRangeException if a correct Type is not set.
    #
    if (!($this.AcceptedValues -contains $Type)) {
      throw [System.ArgumentOutOfRangeException]::New('UpdateRegistryKey requires Type to be a specific value  [' + $this.AcceptedValues + '], not: ' + $Type)
    }
    If (!(Test-Path $Path)) {
      Write-Host ('    Registry path does not exist, creating: ' + $Path)
      New-Item -Path $Path -Force
    }
    $RegItem = Get-ItemProperty $Path -Name $Key -ErrorAction SilentlyContinue
    if ($RegItem) {
      Write-Host ('    Existing: ' + $Path + '\' + $Key + ' = ' + $RegItem.$Key)
    } else {
      Write-Host ('    Key does not exist: ' + $Path + '\' + $Key)
    }
    Write-Host('    Updating: ' + $Path + '\' + $Key + ' [' + $Type + '] = ' + $Value)
    New-ItemProperty -Path $Path -Name $Key -PropertyType $Type -Value $Value -Force
  }

  [void] DeleteRegistryKey([string]$Path, [string]$Key) {
    # Deletes a given registry key.
    #   
    # Registry key shortcuts:
    #    HKLM: HKEY_LOCAL_MACHINE
    #    HKCR: HKEY_CLASSES_ROOT
    #    HKCU: HKEY_CURRENT_USER
    #    HKCC: HKEY_CURRENT_CONFIG
    #    HKU: HKEY_USERS
    #
    # Args:
    #   Path: String registry path. Shortcut usage is ok.
    #   Key: String registry key name.
    #
    # Raises:
    #   System.ArgumenOutOfRangeException if a correct Type is not set.
    #
    $RegItem = Get-ItemProperty $Path -Name $Key -ErrorAction SilentlyContinue
    if ($RegItem) {
      Write-Host ('    Existing: ' + $Path + '\' + $Key + ' = ' + $RegItem.$Key)
      Write-Host ('    Deleting: ' + $Path + '\' + $Key)
      Remove-ItemProperty -Path $Path -Name $Key -Force
    }
  }
}