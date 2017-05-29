<#
.SYNOPSIS
    Windows 10 Tweaker
.DESCRIPTION
    The intended purpose of this program is to provie an easy, trackable and
    Modular mechanism to apply various tweaks that you may want to a Windows
    10 syetem, without dealing with all the shitty code out there (this shitty
    code not withstanding).
   
    All files are hashed and verified by default on launch to verify that code
    you run is the latest and 'safe'. You should never run code from strangers.

    All tweaks require documentation related to where the tweak is and what it
    does, which allows you to select what types of tweaks to apply.

    **Escalated privleges are required**:
    - Unrestricted policy ('Set-ExecutionPolicy Unrestricted' in admin shell)
    - Admin powershell
    - Unblocked modules

    This script will automatically unblock needed modules, update files from
    the public repo if integrity fails, and set/reset ExecutionPolicy when
    running.

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
    specific list of modules back. See blow.

.EXAMPLE
    C:PS> .\tweak.ps1 -List -Classification stable -Catagory telemetry

    Lista all stable telemetry modules for tweek.

    **NOTE**: You must specify both Classification and Catagory if you want a
    specific list of modules back; otherwise all modules are returned due to
    default options that are set.

.NOTES
    Please add additional tweaks to github.com/r-pufky/tweek. All new modules
    are accepted as long as they are not malicious and follow guidelines.   
#>

[cmdletbinding()] 
param(
  [switch]$Unsigned,
  [string]$Catagory = 'all',
  [string]$Classification = 'stable',
  [switch]$DryRun,
  [string]$Tweak = $none,
  [switch]$List
)

. .\ManageExecutionEnvironment.ps1
$EnvironmentManager = [ManageExecutionEnvironment]::New()
try {
  $EnvironmentManager.SetPolicy()
  $EnvironmentManager.UnblockModules($VerbosePreference)

  # Always force re-import in case modules were updated in place.
  Import-Module .\FileManager.psm1 -Force
  $FileManager = NewFileManager
  if (!($Unsigned)) {
    $FileManager.ValidateAndUpdate($VerbosePreference)
  }
  $Modules = $FileManager.ModuleLoader()

  if ($List) {
    foreach ($Module in $Modules.GetEnumerator()) {
      $Module.Value.TweekList($Classification, $Catagory)
    }
    exit
  }

  if ($Tweak) {
    if ($Modules.ContainsKey($Tweak)) {
      $Modules[$Tweak].TweekExecute($DryRun, $Classification, $Catagory, $Tweak)
    } else {
      throw ($Tweak + ' is not a valid module; check valid modules using -List')
    }
    exit
  }

  Write-Output ('Applying ' + $Catagory + ' tweaks ...')
  foreach ($Module in $Modules.GetEnumerator()) {
    $Module.Value.TweekExecute($DryRun, $Classification, $Catagory, $Tweak)
  }
} finally {
  $EnvironmentManager.RestorePolicy()
}