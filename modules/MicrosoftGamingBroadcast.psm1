Using module '..\TweekModule.psm1'

class MicrosoftGamingBroadcast : TweekModule {
  [string[]] $PolicyReferences = @(
    'https://www.tenforums.com/tutorials/8637-turn-off-game-bar-windows-10-a.html'
  )
  [string] $Description = (
    'Disables Microsoft Gaming Broadcasting and DVR.'
  )
  [string] $LongDescription = (
    'This will record and broadcast games you are playing, as well as ' +
    'display an annoying bar when launching a game (Windows + G ' +
    'Notification) Since so many other programs already do this, including ' +
    'graphics drivers themselves this can safetly be disabled without harm. ' +
    'If you play xbox and stream Windows based games however, you should ' +
    'keep this enabled.'
  )
  
  [string] $ManualDescription = (
    "*  win + r > gpedit.msc`n" +
    "   *  Key: Computer Configuration > Administrative Templates > " +
    "Windows Components > Windows Game Recording and Broadcasting`n" +
    '   *  Policy: Enables or Disables Windows Game Recording and ' +
    "Broadcasting = Enabled`n" +
    "*  win + r > regedit`n" +
    '   *  Key: HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\' +
    "GameDVR`n" +
    "      *  DWORD: AppCaptureEnabled = 0`n" +
    "   *  Key: HKEY_CURRENT_USER\System\GameConfigStore`n" +
    "      *  DWORD: GameDVR_Enabled = 0"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::system

  hidden [void] GroupPolicyTweek() {
    $this.GroupPolicy.Update('Machine', 'Software\Policies\Microsoft\Windows\GameDVR', 'AllowGameDVR', 'DWORD', 0)
  }

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR', 'AppCaptureEnabled', 'DWORD', 0)
    $this.Registry.UpdateKey('HKCU:\System\GameConfigStore', 'GameDVR_Enabled', 'DWORD', 0)
  }
}

function Load() {
  return [MicrosoftGamingBroadcast]::New()
}

Export-ModuleMember -Function Load