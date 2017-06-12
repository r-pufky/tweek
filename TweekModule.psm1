# Base TweekModule class for processing Windows 10 configuration tweaks.

Using module .\interfaces\TweekGroupPolicyInterface.psm1
Using module .\interfaces\TweekRegistryInterface.psm1
Using module .\interfaces\TweekServiceInterface.psm1
Using module .\interfaces\TweekTaskSchedulerInterface.psm1
Using module .\interfaces\TweekFileInterface.psm1

# Windows 10 edition key.
# https://en.wikipedia.org/wiki/Windows_10_editions#Baseline_editions
enum WindowsEdition {
  Microsoft_Windows_10_Home
  Microsoft_Windows_10_Pro
  Microsoft_Windows_10_Enterprise
  Microsoft_Windows_10_Eudcation
  Microsoft_Windows_10_Pro_Education
  Microsoft_Windows_10_Enterprise_LTSB
  Microsoft_Windows_10_Mobile_Enterprise
  Microsoft_Windows_10_China_Government_Edition
}

# Windows 10 versions.
# https://en.wikipedia.org/wiki/Windows_10_version_history
enum WindowsVersion {
  v1507 = 1507
  v1511 = 1511
  v1607 = 1607
  v1703 = 1703
}

# Tweak classifications pertaining to each tweak.
enum TweakClassification {
  # stable tweaks are vetted and apply broadly.
  stable
  # New tweaks are automatically classified as unstable. These are *not* run
  # by default
  unstable
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
  #   PolicyReferences:
  #       Array of Strings containing links to reference material for specific
  #       tweak. One reference required.
  #   Description: String short description of tweak.
  #   LongDescription: String long description of tweak. Optional.
  #   Author: String author. Can be email, github ID, etc.
  #   EditionList:
  #       Array of WindowsEdition enums specifying editions of windows that
  #       this tweek *DOES NOT APPPLY* to.
  #   VersionList:
  #       Array of WindowsVersion enums specifying versions of windows that
  #       this tweek *DOES NOT APPLY* to.
  #   Classification:
  #       TweakClassification enum specifying the general state of the module.
  #       Default: stable.
  #   Catagory:
  #       TweakCatagory enum specifying the type of tweak of the module.
  #       Default: telemetry.
  #   Registry:
  #       TweekRegistryInterface object to interact with windows registry.
  #   GroupPolicy:
  #       TweekGroupPolicyInterface object to interact with windows Group
  #       Policy.
  #   Service: TweekServiceInterface object to interact with windows services.
  #   ScheduledTask:
  #       TweekTaskSchedulerInterface object to interact with windows scheduled
  #       tasks.
  #   File: TweekFileInterface object to interact with files.
  #
  [string[]] $PolicyReferences
  [string] $Description
  [string] $LongDescription
  [string] $Author
  [WindowsEdition[]] $EditionList = @()
  [WindowsVersion[]] $VersionList = @()
  [TweakClassification] $Classification = [TweakClassification]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::telemetry
  [TweekRegistryInterface] $Registry = [TweekRegistryInterface]::New()
  [TweekGroupPolicyInterface] $GroupPolicy = [TweekGroupPolicyInterface]::New()
  [TweekServiceInterface] $ServiceInterface = [TweekServiceInterface]::New()
  [TweekTaskSchedulerInterface] $ScheduledTask = [TweekTaskSchedulerInterface]::New()
  [TweekFileInterface] $File = [TweekFileInterface]::New()
  #----------------------
  hidden [switch] $_DryRun
  hidden [switch] $_Testing
  hidden [string] $_Classification
  hidden [string] $_Catagory
  hidden [string] $_Tweak
  hidden [array] $_WindowsVersion
  hidden $_VerbosePreference

  [void] Configure([switch]$DryRun, [switch]$Testing, [string]$Classification, [string]$Catagory, [string]$Tweak, [array]$WindowsVersion, $VerbosePreference) {
    # Configures tweek with options declared on the command line.
    #
    # As modules are dynamically loaded and instantiated, we need to manually
    # setup command line options for tweek execution. This simplifies method
    # and calls for the tweek.
    #
    # Args:
    #   DryRun: Switch if DryRun option was selected on the command line.
    #   Testing: Switch if Test hashes are being used. Disable execution.
    #   Classifcation: String classification specified on the command line.
    #   Catagory: String catagory specified on the command line.
    #   Tweak: String specific tweak to run on the command line.
    #   WindowsVersion:
    #       Array (String, Integer) containing current environment execution
    #       environment.
    #   VerbosePreference: Object containing verbosity option.
    #
    $this._DryRun = $DryRun
    $this._Testing = $Testing
    $this._Classification = $Classification
    $this._Catagory = $Catagory
    $this._Tweak = $Tweak
    $this._WindowsVersion = $WindowsVersion
    $this._VerbosePreference = $VerbosePreference
  }

  hidden [void] GroupPolicyTweek() {
    # Apply tweaks using Group policy objects.
  }

  hidden [void] RegistryTweek() {
    # Apply tweaks using registry objects.
  }

  hidden [void] ServiceTweek() {
    # Apply tweaks using service manipulations.
  }

  hidden [void] ScheduledTaskTweek() {
    # Apply tweaks using task manipulations.
  }

  hidden [void] FileTweek() {
    # Apply tweaks using file manipulations.
  }

  [void] TweekExecute() {
    # System calls this method to apply the Tweak to the system.
    #
    # This contains the logic to determine what action to execute.
    # If you need to change how a tweak is applied, modify _ApplyTweak()
    # in your subclass.
    #
    if (($this._Tweak) -And ($this._Tweak -eq $this.Name())) {
      $this.ExecuteOrDryRun()
    } else {
      if (($this._Catagory -eq 'all') -Or ($this._Catagory -eq $this.Catagory)) {
        if (($this._Classification -eq 'all') -Or ($this._Classification -eq $this.Classification)) {
          $this.ExecuteOrDryRun()
        } 
      }
    }
  }

  [string] TweekList() {
    # System calls this to determine if module should list info.
    #
    #   Classifcation: String classification specified on the command line.
    #   Catagory: String catagory specified on the command line.
    #
    # Returns:
    #   String containing information for this tweek.
    #
    if (($this._Catagory -eq 'all') -Or
        ($this._Catagory -eq $this.Catagory) -Or
        ($this._Classification -eq 'all') -Or
        ($this._Classification -eq $this.Classification)) {
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

  hidden [boolean] VerifyNonBlacklist() {
    # Verify if this tweek should be executed based on Windows edition/version.
    #
    # Returns:
    #   Boolean True if it can be executed, False otherwise.
    #
    $VerbosePreference = $this._VerbosePreference
    if ($this.EditionList -Contains $this._WindowsVersion[0]) {
      Write-Verbose ($this.Name() + ' does not apply to Windows Edition: ' + $this._WindowsVersion[0] + ', skipping.')
      return $false
    }
    if ($this.VersionList -Contains $this._WindowsVersion[1]) {
      Write-Verbose ($this.Name() + ' does not apply to Windows Version: ' + $this._WindowsVersion[1] + ', skipping.')
      return $false
    }
    return $true
  }

  hidden [string] TweekInfo() {
    # Returns a string containing information for this tweek.
    #
    return (
      "`n{0}`n{1}: {2}`nDetailed Description:`n {3}`nReferences:`n {4}`nIncompatible Editions:`n {5}`nIncompatible Version:`n {6}`nClassification: {7}`nCatagory: {8}`nValid Module: {9}`nApplies To Your System?: {10}" -f
      ('-' * 35),
      $this.Name(),
      $this.Description,
      $this.LongDescription,
      ($this.PolicyReferences -join "`n "),
      ($this.EditionList -join "`n "),
      ($this.VersionList -join "`n "),
      $this.Classification,
      $this.Catagory,
      $this.Validate(),
      $this.VerifyNonBlacklist())
  }

  hidden [void] ApplyTweak() {
    # Apply tweak to the system.
    #
    # This is the system method used to apply this tweak to the system.
    # Automatically checks to see if GroupPolicy module is present to execute
    # GPO tweaks.
    #
    Write-Host ('  Applying ' + $this.Name() + ': ' + $this.Description)
    if (Get-Module -ListAvailable -Name PolicyFileEditor) {
      $this.GroupPolicyTweek()
    }
    $this.RegistryTweek()
    $this.ServiceTweek()
    $this.ScheduledTaskTweek()
    $this.FileTweek()
  }

  hidden [void] ExecuteOrDryRun() {
    # Executes tweak or logs a dry run.
    #
    if (!($this._DryRun)) {
      if (!($this.Validate())) {
        Write-Warning ($this.Name() + ': Is not a valid module, NOT executing. Contact the Module author ' + $this.Author)
      } elseif ($this._Testing) {
        Write-Host ('IGNORE: ' + $this.Name() + ' -Testing option used and will not run.')
      } else {
        if ($this.VerifyNonBlacklist()) {
          $this.ApplyTweak()
        }
      }
    } else {
      Write-Host ('Dry Run: ' + $this.Name())
    }
  }
}

Export-ModuleMember -Variable WindowsEdition, WindowsVersion
