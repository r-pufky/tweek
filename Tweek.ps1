<#
.SYNOPSIS
    Windows 10 Tweaker
.DESCRIPTION
    The intended purpose of this program is to provie an easy, trackable and
    Modular mechanism to apply various tweaks that you may want to a Windows
    10 system, without dealing with all the shitty code out there (this shitty
    code not withstanding).
   
    All files are hashed and verified by default on launch to verify that code
    you run is the latest and 'safe'. You should never run code from strangers.

    All tweaks require documentation related to where the tweak is and what it
    does, which allows you to select what types of tweaks to apply.

    **Escalated privleges are required**:
    - Unrestricted policy ('Set-ExecutionPolicy Unrestricted' in admin shell)
    - Admin powershell
    - Unblocked modules
    - PolicyFileEditor (powershell module for GPO editing, NuGet Dependency)

    This script will automatically unblock needed modules, update files from
    the public repo if integrity fails, and set/reset ExecutionPolicy when
    running.

    If the PolicyFileEditor module is not installed, a warning message will be
    displayed and tweeks will still be applied, but without GPO capabilities.
    This could result in half-applied tweeks.

.PARAMETER Unsigned
    Specify to execute modules that do not pass verification hashes.
    **DANGEROUS**. By default, all modules and system files must be verified
    against known good modules from the public repository before they are used.

    Using unsigned also disables updating. You shouldn't use this unless you
    are testing new code or modules.

.PARAMETER Catagory
    What type of tweaks to run.
    Values:   firewall, services, filesystem, telemetry, system, store, all

    Must be used in conjunction with -Class.

.PARAMETER Class
    What class of tweaks should be applied.
    Values: stable, unstable, optional, all

    Unstable modules are signed but haven't been vetted throughly. These could
    be DANGEROUS.

    Optional modules address a specific tweak for hardware or software, and
    shouldn't be run by default for most users.

    Don't use "all" when applying tweaks, you install unsupported tweeks too;
    this is useful to see all tweaks you want to apply (e.g. with -List).

    Must be used in conjunction with -Catagory.

.PARAMETER DryRun
    Simulate running modules instead of actually running them.

.PARAMETER Tweak
    Run only a single Tweak module. This is specified via the Class/filename.

.PARAMETER List
    List all modules, their category and Class and what they do.

.PARAMETER Manual
    Show the manual steps required to apply Tweaks. This is used in conjunction
    with the -List option to display manual tweaking steps for a module in
    addition to the standard information listed for a Tweek.

.PARAMETER NoGroupPolicy
    Do not attempt to use Group Policy modifications for tweeks.

    By default, group policy modifications are included and require the
    GroupPolicy powershell module provided by the PolicyFileEditor module. If
    this is not installed the program will halt execution. This option will
    bypass this.

.PARAMETER InstallGroupPolicy
    Install modules and frameworks required for Group Policy management.

    Instructions to do so manually are here and in warning messages. This just
    does all that automatically for you.

.PARAMETER Testing
    Enable testing mode. This will prevent hashes from being updated from the
    repository before validating them, as well as loading testing modules from
    .\testdata\. DISABLES EXECUTION (e.g. simulates a -DryRun) for normal
    modules.  This is useful to verify hashfile changes when developing, as
    well as writing modules for testing new interfaces.

    You should never use this in NORMAL usage. If you are developing a new
    Tweak that is unrelated to an Interface, you probably want -Unsigned.

.PARAMETER IReallyWantToDoThis
    Acknowledge that a tweek has warned you a manaual step needed to be done
    before it will execute the tweek. This will enable the tweek to apply to
    your system. Tweeks requiring this flag can **DAMAGE YOUR SYSTEM** if you
    don't do the required manual steps before enabling the tweek. Don't take
    this lightly.

.EXAMPLE
    C:\PS> .\Tweek.ps1 -DryRun -Catagory telemetry -Class unstable

    Simulate running all unstable telemetry tweaks against the system.

.EXAMPLE
    C:\PS> .\Tweek.ps1 -Catagory telemetry -Class stable
    
    Run all stable telemetry tweaks against the system. **NOTE** this will
    execute 'stable' modules only. Specify -Class to run a specific
    type.

.EXAMPLE
    C:\PS> .\Tweek.ps1 -Tweak SomeTweek

    Run only a specific tweek against the system. Note: Tweek will still
    determine if it applies to your system.

.EXAMPLE
    C:\PS> .\Tweek.ps1 -List -Catagory all -Class all

    Lists all modules.

.EXAMPLE
    C:PS> .\Tweek.ps1 -List -Class stable -Catagory telemetry

    Lists all stable telemetry modules for tweek.

.EXAMPLE
    C:PS> .\Tweek.ps1 -Class stable -Catagory telemetry -List -Manual

    Lists all stable telemetry modules for tweek, including manual steps to
    enable those tweaks.

.LINK
    Project Source:
      
      https://github.com/r-pufky/tweek

    PolicyFileEditor (Module):
    
      https://www.powershellgallery.com/packages/PolicyFileEditor/2.0.2

    NuGet (Module):

      https://www.powershellgallery.com/packages/NuGet/1.3.3

.NOTES
    Please add additional tweaks to github.com/r-pufky/tweek. All new modules
    are accepted as long as they are not malicious and follow guidelines.
    
    BUGS:
    Currently, there is a bug in powershell that is scheduled to be patched in
    6.1; wherein subclasses and submodules are not reloaded properly even with
    the -Force option set. Until this is patched, you may need to restart your
    powershell environment if a core file was updated.

    https://github.com/PowerShell/PowerShell/issues/2505#issuecomment-263105859
  
#>

[cmdletbinding()] 
param(
  [switch]$Unsigned,
  [string]$Catagory = $none,
  [string]$Class = $none,
  [switch]$DryRun,
  [string]$Tweak = $none,
  [switch]$List,
  [switch]$NoGroupPolicy,
  [switch]$InstallGroupPolicy,
  [switch]$Testing,
  [switch]$Manual,
  [switch]$IReallyWantToDoThis
)

if ($InstallGroupPolicy) {
  Write-Warning ('Group policy management toosl requested to be installed, Installing ...')
  Install-PackageProvider -Name NuGet -Force
  Install-Module PolicyFileEditor -Force
  exit
}

$SwitchSelected = ($Unsigned.IsPresent -Or $DryRun.IsPresent -Or $List.IsPresent -Or $Testing.IsPresent -Or $NoGroupPolicy.IsPresent -Or $Manual.IsPresent)
$Filters = (![String]::IsNullOrWhiteSpace($Catagory) -And ![String]::IsNullOrWhiteSpace($Class))
if ([String]::IsNullOrWhiteSpace($Tweak)) {
  if (($SwitchSelected -And !$Filters) -Or (!$SwitchSelected -And !$Filters)) {
    Write-Host ('Please run the following one of the following commands for help or examples:')
    Write-Host ("`n  Get-Help Tweek.ps1`n`n  Get-Help Tweek.ps1 -Examples`n") -ForegroundColor Green
    exit
  }
}

if (Get-Module -ListAvailable -Name PolicyFileEditor) {
  Import-Module PolicyFileEditor
} else {
  Write-Warning (
    'GroupPolicy powershell modules do not exist. Group policy modifications' +
    ' are DISABLED. Please see "Get-Help Tweek.ps1" or install the ' +
    "PolicyFileEditor powershell module with the following command:`n`n`t" +
    "Install-PackageProvider -Name NuGet -Force`n`t" +
    "Install-Module PolicyFileEditor -Force`n`n" +
    'If you want to force execution, use -NoGroupPolicy option, or use ' +
    '-InstallGroupPolicy option to install required tools.')
  if ($NoGroupPolicy) {
    Write-Warning ("-NoGroupPolicy set, continuing. You've been warned.")
  } else {
    exit
  }
}

. .\ManageExecutionEnvironment.ps1
$EnvironmentManager = [ManageExecutionEnvironment]::New()
try {
  $EnvironmentManager.SetPolicy()
  $EnvironmentManager.UnblockModules($VerbosePreference)
  $EnvironmentManager.MountRegistryDrives()
  $WindowsVersion = $EnvironmentManager.GetWindowsVersion()

  # Always force re-import in case modules were updated in place.
  Import-Module .\FileManager.psm1 -Force
  $FileManager = NewFileManager
  $FileManager.Configure($Testing, $VerbosePreference)
  if (!($Unsigned)) {
    if ($FileManager.ValidateAndUpdate()) {
      Write-Error ('Files were updated. Please RESTART powershell environment. See Help for details.')
      exit
    }
  } else {
    Write-Warning ('COMPROMISED (DANGEROUS FLAG USED): -Unsigned option used, modules CANNOT be trusted but WILL BE executed.')
  }
  $Modules = $FileManager.ModuleLoader('.\modules\')
  if ($Testing) {
    Write-Output ('-Testing option used, injecting test modules ...')
    foreach ($TestModule in ($FileManager.ModuleLoader('.\testdata\')).GetEnumerator()) {
      Write-Verbose ($TestModule.Name)
      $Modules.Set_Item($TestModule.Name, $TestModule.Value)
    }
  }

  Write-Verbose ('Configuring modules ...')
  foreach ($Module in $Modules.GetEnumerator()) {
    $Module.Value.Configure($DryRun, $Testing, $Manual, $IReallyWantToDoThis, $Class, $Catagory, $Tweak, $WindowsVersion, $VerbosePreference)
  }

  if ($List) {
    if ($Tweak) {
      if ($Modules.ContainsKey($Tweak)) {
        $Modules[$Tweak].TweekInfo()
      } else {
        Write-Error ('Specified module does not exist: ' + $Tweak + '; check valid modules using -List')
      }
    } else {
      foreach ($Module in $Modules.GetEnumerator()) {
        $Module.Value.TweekList()
      }
    }
    exit
  }

  if ($Tweak) {
    if ($Modules.ContainsKey($Tweak)) {
      $Modules[$Tweak].TweekExecute()
    } else {
      Write-Error ('Specified modules does not exist: ' + $Tweak + '; check valid modules using -List')
    }
    exit
  }

  Write-Output ('Applying [Catagory:' + $Catagory + ', Class:' + $Class + '] tweaks ...')
  foreach ($Module in $Modules.GetEnumerator()) {
    $Module.Value.TweekExecute()
  }
} finally {
  $EnvironmentManager.RestorePolicy()
}
