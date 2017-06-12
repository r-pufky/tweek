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
    What type of tweaks to run. Default: 'all'.
    Values:   firewall, services, filesystem, telemetry, system, all

.PARAMETER Classification
    What class of tweaks should be applied. Default: 'stable'.
    Values: stable, unstable, optional

    Unstable modules are signed but haven't been vetted throughly. These could
    be DANGEROUS.

    Optional modules address a specific tweak for hardware or software, and
    shouldn't be run by default for most users.

.PARAMETER DryRun
    Simulate running modules instead of actually running them.

.PARAMETER Tweak
    Run only a single Tweak module. This is specified via the Class/filename.

.PARAMETER List
    List all modules, their category and classification and what they do.

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
    
.EXAMPLE
    C:\PS> .\tweak.ps1

    Run all default tweaks against the system.

.EXAMPLE
    C:\PS> .\tweak.ps1 -DryRun

    Simulate running all default tweaks against the system.

.EXAMPLE
    C:\PS> .\tweak.ps1 -Catagory telemetry
    
    Run all telemetry tweaks against the system. **NOTE** this will execute
    'stable' modules only. Specify -Classification to run a specific type.

.EXAMPLE
    c:\PS> .\tweak.ps1 -Catagory telemetry -DryRun

    Simulate running all telemetry tweaks against the system.

.EXAMPLE
    C:\PS> .\tweak.ps1 -Unsigned -Tweak MyNewTweak

    Run MyNewTweak module, do not verify file hashes.

.EXAMPLE
    C:\PS> .\tweak.ps1 -List

    Lists all modules.
    
    **NOTE**: you must specify both Classification and Catagory if you want a
    specific list of modules back. See below.

.EXAMPLE
    C:PS> .\tweak.ps1 -List -Classification stable -Catagory telemetry

    Lists all stable telemetry modules for tweek.

    **NOTE**: You must specify both Classification and Catagory if you want a
    specific list of modules back; otherwise all modules are returned due to
    default options that are set.

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
  [string]$Catagory = 'all',
  [string]$Classification = 'stable',
  [switch]$DryRun,
  [string]$Tweak = $none,
  [switch]$List,
  [switch]$NoGroupPolicy,
  [switch]$InstallGroupPolicy,
  [switch]$Testing
)

if ($InstallGroupPolicy) {
  Write-Warning ('Group policy management toosl requested to be installed, Installing ...')
  Install-PackageProvider -Name NuGet -Force
  Install-Module PolicyFileEditor -Force
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
  if (!($Unsigned)) {
    if ($FileManager.ValidateAndUpdate($VerbosePreference, $Testing)) {
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

  if ($List) {
    foreach ($Module in $Modules.GetEnumerator()) {
      $Module.Value.TweekList($Classification, $Catagory, $WindowsVersion)
    }
    exit
  }

  if ($Tweak) {
    if ($Modules.ContainsKey($Tweak)) {
      $Modules[$Tweak].TweekExecute($DryRun, $Classification, $Catagory, $Tweak, $Testing, $WindowsVersion)
    } else {
      throw ($Tweak + ' is not a valid module; check valid modules using -List')
    }
    exit
  }

  Write-Output ('Applying [Catagory:' + $Catagory + ', Classification:' + $Classification + '] tweaks ...')
  foreach ($Module in $Modules.GetEnumerator()) {
    $Module.Value.TweekExecute($DryRun, $Classification, $Catagory, $Tweak, $Testing, $WindowsVersion)
  }
} finally {
  $EnvironmentManager.RestorePolicy()
}
