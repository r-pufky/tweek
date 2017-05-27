# Base TweakModule class for processing Windows 10 configuration tweaks

# Windows 10 editions
# based on https://en.wikipedia.org/wiki/Windows_10_editions#Baseline_editions 
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

# Windows 10 versions
# based on https://en.wikipedia.org/wiki/Windows_10_version_history
enum WindowsVersion {
  version_1507 = 1507
  version_1511 = 1511
  version_1607 = 1607
  version_1703 = 1703
}

# Tweak classifications
enum TweakClassification {
  stable
  flakey
}

# Tweak Catagories
enum TweakCatagory {
  firewall
  services
  filesystem
  telemetry
  system
}

class TweakModule {
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
    if ($this.GroupPolicyTweak() -And $this.RegistryTweak()) {
      return $true
    }
    return $false
  }

  [string] Name() {
    # Returns the string class name of the object.
    return $this.GetType().FullName
  }
}

Export-ModuleMember -Variable WindowsEdition, WindowsVersion
