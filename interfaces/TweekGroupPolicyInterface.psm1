# Provides interface to Windows registry for Tweek Modules.
#
# To configure a new group policy Tweek:
# 1) Ensure policy you want to set is in default state (e.g unmodified in gpedit.msc)
# 2) List all Group Policy objects currently set:
#
#   Machine Policies:
#   Get-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -All
#
#   User Policies:
#   Get-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\User\registry.pol -All
#
#   Generally, local group policy is set at the Machine level.
#
# 3) Set your group policy tweek with gpedit.msc
# 4) Re-run the above commands to see what changed or was added.
# 5) Use that line for the changed/new data for configuration of group policy tweak.
#

class TweekGroupPolicyInterface {
  [string[]]$AcceptedValues = @('STRING', 'EXPANDSTRING', 'BINARY', 'DWORD', 'MULTISTRING', 'QWORD', 'UNKNOWN')

  [void] UpdateGroupPolicy([string]$PolicyFile, [string]$Key, [string]$Name, [string]$Type, $Data) {
    # Modifies or creates a given group policy key with a value.
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
    #   System.ArgumenOutOfRangeException if a correct PolicyFile is not set or wrong Type keyword.
    #
    if (($PolicyFile -ne 'Machine') -And ($PolicyFile -ne 'User')) {
      throw [System.ArgumentOutOfRangeException]::New("UpdateGroupPolicy requires PolicyFile to be 'Machine' or 'User', not: " + $PolicyFile)
    }
    if (!($this.AcceptedValues -contains $Type)) {
      throw [System.ArgumentOutOfRangeException]::New('UpdateGroupPolicy requires Type to be a specific value  [' + $this.AcceptedValues + '], not: ' + $Type)
    }
    $Policy = "$env:SystemRoot\system32\GroupPolicy\" + $PolicyFile + '\registry.pol'
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
