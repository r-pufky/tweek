# Tweak validator. Manually validate tweak scripts and modules against a
# validate hashlist of files on github. This prevent malicous changes as
# well as providing an update mechanism for the script.
#
# If a hash validation fails, download an updated file and re-verify. If
# it fails again, abort.
#
# Does not cover the case where an additional module was created locally
# and not added into hashfile (e.g. a local module you created). Might
# want to have a toggle for strict / non-strict checking (strict verify
# all files in directory are the only things in the hashlist).

function VerifyFile($valid_hash, $target, $algorithm='SHA256') {
  # Verifies file integrity by comparing file's current hash to verified hash.
  #
  # Args:
  #   target_hash: String known hash to compare with file hash.
  #   target: Item object containing FullName path to file to verify.
  #   algorithm: String algorithm to use for comparision. From
  #       Get-FileHash:Algorithm. Default: SHA256.
  #
  $hash = Get-FileHash $target -Algorithm $algorithm
  if ($valid_hash -eq $hash.hash) {
    return $true
  }
  return $false
}

function ValidateFiles() {
  # Validates files to use with precomputed hashes
  #
  # We'd want to just download an updated hashtable every run when live.
  $integrity_hashes = 'integrity-hashes.sha256'
  foreach ($line in Get-Content $integrity_hashes) {
    $verified_hash, $file_location = $line.split(' *', [System.StringSplitOptions]::RemoveEmptyEntries)
    $file = Get-Item $file_location
    VerifyFile $verified_hash $file.FullName  
  }
}

export-modulemember -function ValidateFiles 