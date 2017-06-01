# Base TweekModule class for processing Windows 10 configuration tweaks

Using module .\interfaces\TweekGroupPolicyInterface.psm1
Using module .\interfaces\TweekRegistryInterface.psm1

# Windows 10 editions based on:
# https://en.wikipedia.org/wiki/Windows_10_editions#Baseline_editions
#
# These help categorize specific tweaks for specific operating systems
# e.g. can only be applied to a specific OS.
enum WindowsEdition {
  home
  pro
  enterprise
  eudcation
  pro_education
  enterprise_ltsb
  mobile_enterprise
  china_government_edition
}

# Windows 10 versions based on:
# https://en.wikipedia.org/wiki/Windows_10_version_history
#
# These are the current numeric 'patch' versions of windows 10. These
# determine the minimal patch level a specific tweak applies to.
enum WindowsVersion {
  version_1507 = 1507
  version_1511 = 1511
  version_1607 = 1607
  version_1703 = 1703
}

# Tweak classifications pertaining to each tweak.
enum TweakClassification {
  # stable tweaks are vetted and apply broadly.
  stable
  # New tweaks are automatically classified as flakey. These are *not* run
  # by default
  flakey
  # Optional tweaks applied to tweaks to specific user hardware or software
  # and should not be applied to a generic windows 10 install. These are
  # *not* run by default.
  optional
}

# Tweak Catagories. This helps sort tweaks into broad categories for filtering.
enum TweakCatagory {
  firewall
  services
  filesystem
  telemetry
  system
  hardware
}

class TweekModule {
  # Base module for specifying a tweak to apply to Windows 10.
  #
  # When creatin a new TweekModule inherit this class and *only* override
  # _GroupPolicyTweak() and _RegistryTweak() methods.
  #
  # Properties:
  #   PolicyReferences: Array of Strings containing links to reference
  #       material for specific tweak. One reference required.
  #   Description: String short description of tweak.
  #   Author: String author. Can be email, github ID, etc.
  #   Edition: WindowsEdition enum specifying the lowest Windows edition this
  #       tweak applies to. Default: home.
  #   Version: WindowsVersion enum specifying the lowest Windows version this
  #       tweak applies to. Default: verison_1507.
  #   Classification: TweakClassification enum specifying the general state
  #       of the module. Default: stable.
  #   Catagory: TweakCatagory enum specifying the type of tweak of the module.
  #       Default: telemetry.
  #   Registry: TweekRegistryInterface object to interact with windows
  #       registry.
  #   GroupPolicy: TweekGroupPolicyInterface object to interact with windows
  #       Group Policy.
  #
  [string[]] $PolicyReferences
  [string] $Description
  [string] $Author
  [WindowsEdition] $Edition = [WindowsEdition]::home
  [WindowsVersion] $Version = [WindowsVersion]::version_1507
  [TweakClassification] $Classification = [TweakClassification]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::telemetry
  [TweekRegistryInterface] $Registry = [TweekRegistryInterface]::New()
  [TweekGroupPolicyInterface] $GroupPolicy  = [TweekGroupPolicyInterface]::New()

  hidden [void] GroupPolicyTweek() {
    # Apply tweaks using Group policy objects.
    throw ('Must override GroupPolicyTweek()')
  }

  hidden [void] RegistryTweek() {
    # Apply tweaks using registry objects.
    throw ('Must override RegistryTweek()')
  }

  [void] TweekExecute([switch]$DryRun, [string]$Classification, [string]$Catagory, [string]$Tweak, [switch]$TestHashes) {
    # System calls this method to apply the Tweak to the system.
    #
    # This contains the logic to determine what action to execute.
    # If you need to change how a tweak is applied, modify _ApplyTweak()
    # in your subclass.
    #
    # Args:
    #   DryRun: Switch if DryRun option was selected on the command line.
    #   Classifcation: String classification specified on the command line.
    #   Catagory: String catagory specified on the command line.
    #   Tweak: String specific tweak to run on the command line.
    #   TestHashes: Switch if Test hashes are being used. Disable execution.
    #
    if (($Tweak) -And ($Tweak -eq $this.Name())) {
      $this.ExecuteOrDryRun($DryRun, $TestHashes)
    } else {
      if (($Catagory -eq 'all') -Or ($Catagory -eq $this.Catagory)) {
        if ($Classification -eq $this.Classification) {
          $this.ExecuteOrDryRun($DryRun, $TestHashes)
        } 
      }
    }
  }

  [string] TweekList([string]$Classification, [string]$Catagory) {
    # System calls this to determine if module should list info.
    #
    #   Classifcation: String classification specified on the command line.
    #   Catagory: String catagory specified on the command line.
    #
    #   BUG(?): Since classification and catagory have default values, when
    #     -List is used with one of these but not the other, it assumes all
    #     tweaks are returned. It's only properly scoped when using -List AND
    #     both Catagory and Classification.
    #
    # Returns:
    #   String containing information for this tweek.
    #
    if (($Catagory -eq 'all') -Or
        ($Catagory -eq $this.Catagory) -Or
        ($Classification -eq $this.Classification)) {
      return $this.TweekInfo()
    }
    return $null
  }

  [boolean] Validate() {
    # Validates minimum requirements for tweak to be executed.
    #
    # Returns:
    #   Boolean True if the tweak is valid, False otherwise.
    if ($this.PolicyReferences -eq $null) {
      return $false
    }
    if ($this.Description -eq $null) {
      return $false
    }
    if ($this.Author -eq $null) {
      return $false
    }
    return $true
  }

  [string] Name() {
    # Returns the string class name of the object.
    return $this.GetType().FullName
  }

  hidden [string] TweekInfo() {
    # Returns a string containing information for this tweek.
    return (
      "`n{0}`n{1}: {2}`nReferences:`n  {3}`nEdition: {4}`nMinimum Version: {5}`nClassification: {6}`nCatagory: {7}`nValid Module: {8}" -f
      ('-' * 35),
      $this.Name(),
      $this.Description,
      ($this.PolicyReferences -join "`n  "),
      $this.Edition,
      $this.Version,
      $this.Classification,
      $this.Catagory,
      $this.Validate())
  }

  hidden [void] ApplyTweak() {
    # Apply tweak to the system.
    #
    # This is the system method used to apply this tweak to the system.
    # Automatically checks to see if GroupPolicy module is present to execute
    # GPO tweaks.
    #
    Write-Host ('  Applying ' + $this.Name())
    if (Get-Module -ListAvailable -Name PolicyFileEditor) {
      $this.GroupPolicyTweek()
    }
    $this.RegistryTweek()
  }

  hidden [void] ExecuteOrDryRun([switch]$DryRun, [switch]$TestHashes) {
    # Executes tweak or logs a dry run.
    #
    # Args:
    #   DryRun: Switch if DryRun option was selected on command line.
    #   TestHashes: Switch if Test hashes are being used. Disable execution.
    #
    if (!($DryRun)) {
      if (!($this.Validate())) {
        Write-Warning ($this.Name() + ': Is not a valid module, NOT executing. Contact the Module author ' + $this.Author)
      } elseif ($TestHashes) {
        Write-Host ('IGNORE: ' + $this.Name() + ' is not validated and will not run.')
      } else {
        $this.ApplyTweak()
      }
    } else {
      Write-Host ('Dry Run: ' + $this.Name())
    }
  }
}

Export-ModuleMember -Variable WindowsEdition, WindowsVersion
