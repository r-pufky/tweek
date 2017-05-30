# File manager for tweek.
#
# This module handles dynamically verifying and loading modules for tweek.
# In addition, it will download the latest hashes of files and modules,
# Updating them in place if they fail hash verification.
#
# These modules must be Unblocked before they can be imported.

class FileManager {
  [string] $URI_BASE = 'https://raw.githubusercontent.com/r-pufky/tweek/master'
  [string] $INTEGRITY_HASHES = 'integrity-hashes.sha256'

  hidden [boolean] VerifyFile([string]$ValidHash, $Target) {
    # Verifies file integrity by comparing file's current hash to verified hash.
    #
    # Args:
    #   ValidHash: String known hash to compare with file hash.
    #   Target: Item object containing FullName path to file to verify.
    #
    $Hash = Get-FileHash $Target -Algorithm 'SHA256'
    if ($ValidHash -eq $Hash.hash) {
      return $true
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
    # Returns
    #   Hashtable containing {[string] relative file location: [string] hash}
    #
    $Hashes = @{}
    if (!(Test-Path $this.INTEGRITY_HASHES)) {
      New-Item $this.INTEGRITY_HASHES -Type file -Force
    }
    $this.UpdateFile((Get-Item $this.INTEGRITY_HASHES))
    foreach ($Line in Get-Content $this.INTEGRITY_HASHES) {
      $VerifiedHash, $FileLocation = $Line.split(' *', [System.StringSplitOptions]::RemoveEmptyEntries)
      $Hashes.Add($FileLocation, $VerifiedHash)
    }
    return $Hashes
  }

  [void] ValidateAndUpdate($VerbosePreference) {
    # Validates and updates all files related to tweek.
    #
    # A validation hashfile is downloaded and a current file list is generated
    # from tweek and validated against those hashes. If the file fails
    # validate, it is re-downloaded and re-checked. A second failure raise an
    # exception. Once the existing files are compared to the hashlist any
    # remaining hashes in the hashfile are used to download the missing files
    # and revalidate them.
    #
    # Args:
    #   VerbosePreference: Object containing verbosity option.
    #
    # Raises:
    #   System.IO.FileLoadException for validation error.
    #
    $Hashes = $this.GetIntegrityHashes()
    foreach ($File in Get-ChildItem '.' -Include *.psm1, *.ps1 -Recurse) {
      $FileKey = ($File.FullName -split "tweek",2 | Select-Object -Last 1 | % {$_.split('\',2)} | Select-Object -Last 1)
      Write-Verbose ('Validating from filesystem: ' + $FileKey)
      if ($this.VerifyFile($Hashes[$FileKey], $File.FullName)) {
        $Hashes.Remove($FileKey)
        continue
      }
      $this.UpdateFile($File)
      if ($this.VerifyFile($Hashes[$FileKey], $File.FullName)) {
        $Hashes.Remove($FileKey)
        continue
      } else {
        throw [System.IO.FileLoadException]::new($File.FullName + ' failed to validate.')
      }
    }

    if ($Hashes.Count -ne 0) {
      foreach ($Hash in $Hashes.GetEnumerator()) {
        Write-Verbose ('Validating from hashtable: ' + $Hash.Name)
        $File = New-Item $Hash.Name -Type file -Force
        $this.UpdateFile($File)
        if (!($this.VerifyFile($Hash.Value, $File.FullName))) {
          throw [System.IO.FileLoadException]::new($File.FullName + ' failed to validate [hashlist].')
        }
      }      
    }
  }

  [hashtable] ModuleLoader() {
    # Dynamically load all Tweek modules for use.
    # 
    # Returns:
    #   Hashtable containing loaded TweekModule class objects
    #   {[string] ClassName: [TweakModule] tweek object}
    #
    $Modules = @{}
    foreach ($File in Get-ChildItem '.\modules\' -Filter '*.psm1') {
      Import-Module $File.FullName -Force
      $ClassName = ((Get-Module $File.BaseName).ImplementingAssembly.DefinedTypes | where IsPublic).Name
      $ModuleObject = invoke-command -scriptblock (get-command 'Load' -CommandType Function -Module $ClassName).ScriptBlock
      $Modules.Add($ModuleObject.Name(), $ModuleObject)
    }
    return $Modules
  }
}

function NewFileManager() {
  return [FileManager]::New()
}

Export-ModuleMember -Function NewFileManager