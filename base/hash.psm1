# convience methods for processing tweaks

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

export-modulemember -function VerifyFile 