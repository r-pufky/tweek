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

  [boolean] VerifyFile($valid_hash, $target) {
    # Verifies file integrity by comparing file's current hash to verified hash.
    #
    # Args:
    #   target_hash: String known hash to compare with file hash.
    #   target: Item object containing FullName path to file to verify.
    #
    $hash = Get-FileHash $target -Algorithm 'SHA256'
    if ($valid_hash -eq $hash.hash) {
      return $true
    }
    return $false
  }

  [void] UpdateFile($file) {
    # Updates a given file in place, using current working directory
    #
    # Args:
    #   file: Item object containing the location of file to write locally.
    #
    # Returns:
    #   Boolean True if successful, False otherwise.
    #
    $uri = $this.URI_BASE + $this.ConvertUri($file)
    Write-Host ('Updating: ' + $file.FullName + ' (' + $uri + ')')
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($uri, $file)
  }

  [string] ConvertUri($file) {
    # Convert a given Item object to a relative URI path.
    #
    # Assumes that file is within the 'tweek' directory. Converts the relative
    # path after 'tweek' into URI (NOT-ESCAPED) string.
    #
    # Returns:
    #   String containing the relative URI for the file resource.
    #
    return $file.FullName -split "tweek",2 | Select-Object -Last 1 | % {$_.replace('\','/')}
  }

  [hashtable] GetIntegrityHashes() {
    # Returns integrity hashes for tweek.
    #
    # The hashfile is downloaded from the repository, loaded and returned.
    #
    # Returns
    #   Hashtable containing {[string] relative file location: [string] hash}
    #
    $hashes = @{}
    if (!(Test-Path $this.INTEGRITY_HASHES)) {
      New-Item $this.INTEGRITY_HASHES -Type file -Force
    }
    $this.UpdateFile((Get-Item $this.INTEGRITY_HASHES))
    foreach ($line in Get-Content $this.INTEGRITY_HASHES) {
      $verified_hash, $file_location = $line.split(' *', [System.StringSplitOptions]::RemoveEmptyEntries)
      $hashes.Add($file_location, $verified_hash)
    }
    return $hashes
  }

  [void] ValidateAndUpdate() {
    # Validates and updates all files related to tweek.
    #
    # A validation hashfile is downloaded and a current file list is generated
    # from tweek and validated against those hashes. If the file fails
    # validate, it is re-downloaded and re-checked. A second failure raise an
    # exception. Once the existing files are compared to the hashlist any
    # remaining hashes in the hashfile are used to download the missing files
    # and revalidate them.
    #
    # Raises:
    #   System.IO.FileLoadException for validation error.
    #
    $hashes = $this.GetIntegrityHashes()
    foreach ($file in Get-ChildItem '.' -Include *.psm1, *.ps1 -Recurse) {
      $file_key = ($file.FullName -split "tweek",2 | Select-Object -Last 1 | % {$_.split('\',2)} | Select-Object -Last 1)
      Write-Debug ('Validating from filesystem: ' + $file_key)
      if ($this.VerifyFile($hashes[$file_key], $file.FullName)) {
        $hashes.Remove($file_key)
        continue
      }
      $this.UpdateFile($file)
      if ($this.VerifyFile($hashes[$file_key], $file.FullName)) {
        $hashes.Remove($file_key)
        continue
      } else {
        throw [System.IO.FileLoadException]::new($file.FullName + ' failed to validate.')
      }
    }

    if ($hashes.Count -ne 0) {
      foreach ($hash in $hashes.GetEnumerator()) {
        Write-Debug ('Validating from hashtable: ' + $hash.Name)
        $file = New-Item $hash.Name -Type file -Force
        $this.UpdateFile($file)
        if (!($this.VerifyFile($hash.Value, $file.FullName))) {
          throw [System.IO.FileLoadException]::new($file.FullName + ' failed to validate [hashlist].')
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
    $modules = @{}
    foreach ($file in Get-ChildItem '.\modules\' -Filter '*.psm1') {
      Import-Module $file.FullName -Force
      $class_name = ((Get-Module $file.BaseName).ImplementingAssembly.DefinedTypes | where IsPublic).Name
      $class_loader = (get-command 'Load' -CommandType Function -Module $class_name).ScriptBlock
      $temp = invoke-command -scriptblock $class_loader
      $modules.Add($temp.Name(), $temp)
    }
    return $modules
  }
}

function NewFileManager() {
  return [FileManager]::New()
}

Export-ModuleMember -Function NewFileManager