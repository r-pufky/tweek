# TODO: As of 1607, you potentially no longer need to set quick access in
#   explorer before running the regsitry tweek. Verify this.

Using module '..\TweekModule.psm1'

class ExplorerQuickAccessPane : TweekModule {
  [string[]] $PolicyReferences = @(
    'http://www.winhelponline.com/blog/remove-quick-access-other-shell-folders-file-explorer/#quickaccess_v1607',
    'https://www.maketecheasier.com/remove-quick-access-file-explorer/'
  )
  [string] $Description = (
    "Disables Explorer's Quick Access Pane."
  )
  [string] $LongDescription = (
    'The File Explorer in Windows 8 and 10 by default displays at the top ' +
    'those six shell folders, and a couple of shell folders pinned on to ' +
    "the navigation pane.`n`n" +
    'The six shell folders namely Desktop, Documents, Downloads, Music, ' +
    'Pictures, and Videos show up above the fold not only cluttering the ' +
    'area but pushing the disk drives category down, which some users ' +
    "dislike.`n`n" +
    'You **NEED** to set Set explorer to use this pc instead of quick ' +
    "access before running this tweek, or this will break your system.`n`n" +
    "Explorer > file > folder options > Open File Explorer To = This PC`n`n" +
    'SEE REFERENCES. THIS IS A POTENTIALLY SYSTEM BREAKING TWEEK.'
  )
  [string] $ManualDescription = (
    "*  win + r > regedit`n" +
    '   *  Key: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion' +
    "\Explorer`n" +
    "      *  DWORD: HubMode = 1`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'

  [WindowsVersion[]] $VersionList = @(
    [WindowsVersion]::v1507,
    [WindowsVersion]::v1511
  )
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::system
  [boolean] $SystemBreaking = $true

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'HubMode', 'DWORD', 1)
  }
}

function Load() {
  return [ExplorerQuickAccessPane]::New()
}

Export-ModuleMember -Function Load