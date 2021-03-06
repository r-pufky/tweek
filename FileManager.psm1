﻿# File manager for tweek.
#
# This module handles dynamically verifying and loading modules for tweek.
# In addition, it will download the latest hashes of files and modules,
# Updating them in place if they fail hash verification.
#
# These modules must be Unblocked before they can be imported.

class FileManager {
  [string] $URI_BASE = 'https://raw.githubusercontent.com/r-pufky/tweek/master'
  [string] $INTEGRITY_HASHES = 'integrity-hashes.sha256'
  hidden [switch] $_Testing
  hidden $_VerbosePreference

  [void] Configure([switch]$Testing, $VerbosePreference) {
    # Configures FileManager with options declared on command line.  
    #
    # As modules are dynamically loaded and instantiated, we need to manually
    # setup command line options for FileManager. This simplifies method
    # and calls.
    #
    # Args:
    #   Testing: Switch containing whether local testing is enabled. 
    #   VerbosePreference: Object containing verbosity option.
    #
    $this._Testing = $Testing
    $this._VerbosePreference = $VerbosePreference
  }

  hidden [boolean] VerifyFile([string]$ValidHash, $Target) {
    # Verifies file integrity by comparing file current hash to verified hash.
    #
    # Args:
    #   ValidHash: String known hash to compare with file hash.
    #   Target: Item object containing FullName path to file to verify.
    #
    if (Test-Path $Target) {
      $Hash = Get-FileHash $Target -Algorithm 'SHA256'
      if ($ValidHash -eq $Hash.hash) {
        return $true
      }
    }
    return $false
  }

  hidden [void] UpdateFile($File) {
    # Updates a given file in place, using current working directory
    #
    # Args:
    #   File: Item object containing the location of file to write locally.
    #
    # Returns:
    #   Boolean True if successful, False otherwise.
    #
    $Uri = $this.URI_BASE + $this.ConvertUri($File)
    Write-Host ('Updating: ' + $File.FullName + ' (' + $Uri + ')')
    $Client = New-Object System.Net.WebClient
    $Client.DownloadFile($Uri, $File)
  }

  hidden [string] ConvertUri($File) {
    # Convert a given Item object to a relative URI path.
    #
    # Assumes that file is within the 'tweek' directory. Converts the relative
    # path after 'tweek' into URI (NOT-ESCAPED) string.
    #
    # Args:
    #   File: Item object containing the location of file to write locally.
    # 
    # Returns:
    #   String containing the relative URI for the file resource.
    #
    return $File.FullName -split "tweek",2 | Select-Object -Last 1 | % {$_.replace('\','/')}
  }

  hidden [hashtable] GetIntegrityHashes() {
    # Returns integrity hashes for tweek.
    #
    # The hashfile is downloaded from the repository, loaded and returned.
    #
    # If local testing is set, then the hashfile is not updated before loading
    # and returning validation hashes.
    #
    # Returns
    #   Hashtable containing {[string] relative file location: [string] hash}
    #
    $Hashes = @{}
    if (!(Test-Path $this.INTEGRITY_HASHES)) {
      New-Item $this.INTEGRITY_HASHES -Type file -Force
    }
    if (!($this._Testing)) {
      $this.UpdateFile((Get-Item $this.INTEGRITY_HASHES))
    } else {
      Write-Warning ('COMPROMISED (DANGEROUS FLAG USED): -Testing option used, not updating hashes from trusted source.')
    }
    foreach ($Line in Get-Content $this.INTEGRITY_HASHES) {
      $VerifiedHash, $FileLocation = $Line.split(' *', [System.StringSplitOptions]::RemoveEmptyEntries)
      $Hashes.Add($FileLocation, $VerifiedHash)
    }
    return $Hashes
  }

  [boolean] ValidateAndUpdate() {
    # Validates and updates all files related to tweek.
    #
    # A validation hashfile is downloaded and a current file list is generated
    # from tweek and validated against those hashes. If the file fails
    # validate, it is re-downloaded and re-checked. A second failure raise an
    # exception. Once the existing files are compared to the hashlist any
    # remaining hashes in the hashfile are used to download the missing files
    # and revalidate them.
    #
    # If local testing is set, then the hashfile is not updated before running
    # validation checks, and updates are not downloaded. This is only useful
    # to test hash updates.
    #
    # Raises:
    #   System.IO.FileLoadException for validation error.
    #
    # Returns:
    #   Boolean True if files were update, False otherwise. This only exists
    #   until -Force option bug in powershell is fixed.
    #
    $VerbosePreference = $this._VerbosePreference
    $UpdatedFiles = $false
    $Hashes = $this.GetIntegrityHashes()
    foreach ($File in Get-ChildItem '.' -Include *.psm1, *.ps1 -Recurse) {
      $FileKey = ($File.FullName -split "tweek",2 | Select-Object -Last 1 | % {$_.split('\',2)} | Select-Object -Last 1)
      Write-Verbose ('Validating from filesystem: ' + $FileKey)
      if ($this.VerifyFile($Hashes[$FileKey], $File.FullName)) {
        $Hashes.Remove($FileKey)
        continue
      }
      if (!($this._Testing)) {
        $this.UpdateFile($File)
        $UpdatedFiles = $true
      } else {
        Write-Warning ('COMPROMISED (Hash integrity): -Testing option selected, ' + $FileKey + ' failed verification, not downloading.')
      }
      if (($this.VerifyFile($Hashes[$FileKey], $File.FullName)) -Or ($this._Testing)) {
        $Hashes.Remove($FileKey)
        continue
      } else {
        throw [System.IO.FileLoadException]::new($File.FullName + ' failed to validate.')
      }
    }

    if ($Hashes.Count -ne 0) {
      foreach ($Hash in $Hashes.GetEnumerator()) {
        Write-Verbose ('Validating from hashtable: ' + $Hash.Name)
        if (!($this._Testing)) {
          $File = New-Item $Hash.Name -Type file -Force
          $this.UpdateFile($File)
          $UpdatedFiles = $true
          if (!($this.VerifyFile($Hash.Value, $File.FullName))) {
            throw [System.IO.FileLoadException]::new($File.FullName + ' failed to validate [hashlist].')
          }
        } else {
          Write-Warning ('COMPROMISED (Hash integrity): -Testing option selected, ' + $Hash.Name + ' failed verification, not downloading.')
        }
      }      
    }
    return $UpdatedFiles
  }

  [hashtable] ModuleLoader($ModulePath) {
    # Dynamically load all Tweek modules for use.
    # 
    # Args:
    #   ModulePath: String relative path of modules to load.
    #
    # Returns:
    #   Hashtable containing loaded TweekModule class objects
    #   {[string] ClassName: [TweakModule] tweek object}
    #
    $VerbosePreference = $this._VerbosePreference
    Write-Verbose ('Loading Modules ...')
    $Modules = @{}
    foreach ($File in Get-ChildItem $ModulePath -Filter '*.psm1') {
      Import-Module $File.FullName -Force
      $ClassName = ((Get-Module $File.BaseName).ImplementingAssembly.DefinedTypes | where IsPublic).Name
      $ModuleObject = invoke-command -scriptblock (get-command 'Load' -CommandType Function -Module $ClassName).ScriptBlock
      Write-Verbose ($ModuleObject.Name() + ' loaded; indexing ...')
      $Modules.Add($ModuleObject.Name(), $ModuleObject)
    }
    return $Modules
  }
}

function NewFileManager() {
  return [FileManager]::New()
}

Export-ModuleMember -Function NewFileManager