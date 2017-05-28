# Base TweekModule class for processing Windows 10 configuration tweaks

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
  # Properties:
  #   policy_references: Array of Strings containing links to reference
  #       material for specific tweak. One reference required.
  #   description: String short description of tweak.
  #   edition: WindowsEdition enum specifying the lowest Windows edition this
  #       tweak applies to. Default: home.
  #   version: WindowsVersion enum specifying the lowest Windows version this
  #       tweak applies to. Default: verison_1507.
  #   classification: TweakClassification enum specifying the general state
  #       of the module. Default: stable.
  #   catagory: TweakCatagory enum specifying the type of tweak of the module.
  #       Default: telemetry.
  #
  [string[]] $policy_references
  [string] $description
  [WindowsEdition] $edition = [WindowsEdition]::home
  [WindowsVersion] $version = [WindowsVersion]::version_1507
  [TweakClassification] $classification = [TweakClassification]::stable
  [TweakCatagory] $catagory = [TweakCatagory]::telemetry

  [boolean] Validate() {
    # Validates minimum requirements for tweak to be executed.
    #
    # Returns:
    #   Boolean True if the tweak is valid, False otherwise.
    if ($this.policy_references -eq $null) {
      return $false
    }
    if ($this.descripttion -eq $null) {
      return $false
    }
    return $true
  }

  [boolean] GroupPolicyTweak() {
    # Apply tweak using Group policy objects.
    #
    # Returns:
    #   Boolean True if the tweak applied successfully, False otherwise.
    return $false
  }

  [boolean] RegistryTweak() {
    # Apply tweak using registry editor.
    #
    # Returns:
    #   Boolean True if the tweak applied successfully, false otherwise.
    return $false
  }

  [boolean] ApplyTweak() {
    # Apply all tweaks to the system.
    #
    # Returns:
    #   Boolean True if the tweak applied successfully, False otherwise.
    Write-Host ('Applying ' + $this.Name())
    if ($this.GroupPolicyTweak() -And $this.RegistryTweak()) {
      return $true
    }
    return $false
  }

  [string] Name() {
    # Returns the string class name of the object.
    return $this.GetType().FullName
  }

  [string] TweakInfo() {
    # Returns a string containing information for this tweek.
    return (
      "`n{0}`n{1}: {2}`nReferences:`n  {3}`nEdition: {4}`nMinimum Version: {5}`nClassification: {6}`nCatagory: {7}`nValid Module: {8}" -f
      ('-' * 35),
      $this.name(),
      $this.description,
      ($this.policy_references -join "`n  "),
      $this.edition,
      $this.version,
      $this.classification,
      $this.catagory,
      $this.Validate())
  }
}

Export-ModuleMember -Variable WindowsEdition, WindowsVersion
