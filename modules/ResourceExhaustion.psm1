Using module '..\TweekModule.psm1'

class ResourceExhaustion : TweekModule {
  [WindowsEdition[]] $EditionList = @([WindowsEdition]::Microsoft_Windows_10_Home)
  [string[]] $PolicyReferences = @(
    'https://www.autoitscript.com/forum/topic/177749-stopping-windows-10-from-auto-closing-programs-to-free-up-ram/'
  )
  [string] $Description = (
    'Disable auto-closing of programs when memory is low.'
  )
  [string] $LongDescription = (
    'Windows 10 will automatically close open and active programs if memory ' +
    'is nearly full on the system. For systems with limited RAM, this can ' +
    'lead to games closing automatically while playing them or applications ' +
    'closing during use; with potential data loss.'
  )
  [string] $ManualDescription = (
    "*  win + r > gpedit.msc`n" +
    "   *  Key: Computer Configuration > Administrative Templates > System " +
    "> Troubleshooting and Diagnostics > " +
    "Windows Resource Exhaustion Detection and Resolution`n" +
    "   * Policy: Configure Scenario Execution Level = Disabled"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::services

  hidden [void] GroupPolicyTweek() {
    $this.GroupPolicy.Update('Machine', 'SOFTWARE\Policies\Microsoft\Windows\WDI\{3af8b24a-c441-4fa4-8c5c-bed591bfa867}', 'ScenarioExecutionEnabled', 'DWORD', 0)
  }
}

function Load() {
  return [ResourceExhaustion]::New()
}

Export-ModuleMember -Function Load