# Provides interface to Windows registry for Tweek Modules.
#
# TODO: abstract comments into constants to use in this class.
#

class TweekGroupPolicyInterface {
  [string]$MachinePolicy = "$env:SystemRoot\system32\GroupPolicy\Machine\registry.pol"
  [string]$UserPolicy = "$env:SystemRoot\system32\GroupPolicy\User\registry.pol"

  [void] UpdateGroupPolicy([string]$PolicyFile, [string]$Key, [string]$Name, [string]$Type, $Data) {
    # Modifies or creates a given group policy key with a value.
    #
    # $env:systemroot\system32\GroupPolicy\Machine\
    # $env:systemroot\system32\GroupPolicy\User\
    #
    # Set policies wanted with gpedit.msc, then do
    # Get-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -All
    #  - see modified policies there
    #
    #  Enabled = 1
    #  Disable = 0
    #  Not configured = removed from policy list.
    #
    # To set a policy:
    # ry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol
    # -Key Software\Policies\Microsoft\Windows\GameDVR
    #  -ValueName AllowGameDVR -Type 'DWORD' -Data 0
    #
    # Args:
    #   PolicyFile: String 'Machine' or 'User' local group policy file to modify.
    #   Key: String group policy key to modify.
    #   Name: String group policy Name to modify.
    #   Type: String group policy key data type. Valid types:
    #       STRING, EXPANDSTRING, BINARY, DWORD, MULTISTRING, QWORD, UNKNOWN
    #       (reg_sz, reg_expand_sz, reg_binary, reg_dword, reg_multi_sz, reg_qword, reg_resource_list)
    #   Value: Data to load into the key name.
    #
    # Raises:
    #   System.ArgumenOutOfRangeException if a correct PolicyFile is not set.
    #
    if (($PolicyFile -ne 'Machine') -And ($PolicyFile -ne 'User')) {
      throw [System.ArgumentOutOfRangeException]::New("UpdateGroupPolicy requires PolicyFile to be 'Machine' or 'User', not: " + $PolicyFile)
    }
    $AcceptedValues = @('STRING', 'EXPANDSTRING', 'BINARY', 'DWORD', 'MULTISTRING', 'QWORD', 'UNKNOWN')
    if (!($AcceptedValues -contains $Type)) {
      throw [System.ArgumentOutOfRangeException]::New('UpdateGroupPolicy requires Type to be a specific value  [' + $AcceptedValues + '], not: ' + $Type)
    }
    #$Policy = "$env:SystemRoot\system32\GroupPolicy\" + $PolicyFile + '\registry.pol'
    $Policy = $this.MachinePolicy
    Write-Host ($Policy)
    $PolicyItem = Get-PolicyFileEntry -Path $Policy -Key $Key -ValueName $Name
    If ($PolicyItem) {
      Write-Host ('    Existing Group Policy: ' + $PolicyItem.Key + '\' + $PolicyItem.ValueName + ' [' + $PolicyItem.Type + '] = ' + $PolicyItem.Data)
    } else {
      Write-Host ('    Group Policy Does Not Exist: ' + $Key + '\' + $Name)
    }
    Write-Host('    Updating Group Policy: ' + $Key + '\' + $Name + ' [' + $Type + '] = ' + $Data)
    Set-PolicyFileEntry -Path $Policy -Key $Key -ValueName $Name -Type $Type -Data $Data
  }

  [void] DeleteGroupPolicy([string]$PolicyFile, [string]$Key, [string]$Name) {
    # Deletes a given group policy.
    # 
    # Args:
    #   PolicyFile: String 'Machine' or 'User' local group policy file to modify.
    #   Key: String group policy key to modify.
    #   Name: String group policy Name to modify.
    #
    # Raises:
    #   System.ArgumenOutOfRangeException if a correct PolicyFile is not set.
    #
    if (($PolicyFile -ne 'Machine') -And ($PolicyFile -ne 'User')) {
      throw [System.ArgumentOutOfRangeException]::New("DeleteGroupPolicy requires PolicyFile to be 'Machine' or 'User', not: " + $PolicyFile)
    }
    $Policy = "$env:SystemRoot\system32\GroupPolicy\" + $PolicyFile + '\registry.pol'
    $PolicyItem = Get-PolicyFileEntry -Path $Policy -Key $Key -ValueName $Name
    if ($PolicyItem) {
      Write-Host ('    Existing Group Policy: ' + $PolicyItem.Key + '\' + $PolicyItem.ValueName + ' [' + $PolicyItem.Type + '] = ' + $PolicyItem.Data)
      Write-Host ('    Deleting: ' + $Key + '\' + $Name)
      Remove-PolicyFileEntry -Path $Policy -Key $Key -ValueName $Name
    }
  }
}
