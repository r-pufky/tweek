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
    **DANGEROUS**. By default, all modules must be verified against known good
    modules from the public repository before they are used. Useful for testing
    new modules.
.PARAMETER Catagory
    What type of tweaks to run. Default: 'all'.
    Values:   firewall, services, filesystem, telemetry, system, all
.PARAMETER Classification
    What class of tweaks should be applied. Default: 'stable'.
    Values: stable, unstable

    Unstable modules are signed but haven't been vetted throughly. These could
    be DANGEROUS.
.PARAMETER DryRun
    Specify to dry run the script.
.PARAMETER Tweak
    Run only a single Tweak module. This is specified via the Class/filename.
.EXAMPLE
    C:\PS> .\tweak.ps1

    Run all default tweaks against the system.
.EXAMPLE
    C:\PS> .\tweak.ps1 -DryRun

    Simulate running all default tweaks against the system.
.EXAMPLE
    C:\PS> .\tweak.ps1 -Catagory telemetry
    
    Run all telemetry tweaks against the system.
.EXAMPLE
    C:\PS> .\tweak.ps1 -Unsigned -Tweak MyNewTweak

    Run MyNewTweak module, do not verify file hash.
.NOTES
    Please add additional tweaks to github.com/r-pufky/tweaker. All new modules
    are accepted as long as they are not malicious and follow guidelines.   
#>

param(
  [switch]$Unsigned,
  [string]$Catagory = 'all',
  [string]$Classification = 'stable',
  [switch]$DryRun,
  [string]$Tweak = $none
)

. .\ManageExecutionEnvironment.ps1
Import-Module .\base\validator.psm1
Import-Module .\base\update.psm1
Import-Module .\base\tweak.psm1
Import-Module .\base\hash.psm1


Write-Output 'Ensuring permissions are set properly ...'
$environment_manager = [ManageExecutionEnvironment]::New()
$environment_manager.SetPolicy()
$environment_manager.UnblockModules()

if (!$Unsigned) {
  

$environment_manager.RestorePolicy()