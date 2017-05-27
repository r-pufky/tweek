# File updater

function UpdateFile($uri, $file) {
  # Updates a given file in place, using current working directory
  #
  # Args:
  #   uri: String URI location of the file in repository.
  #   file: String location of file to write locally.
  #
  # Returns:
  #   Boolean True if successful, False otherwise.
  #
  Write-Output ('Updating: ' + $file + ' from: ' + $uri + ' ...')
  $client = New-Object System.Net.WebClient
  $client.DownloadFile($uri, $file)
  Write-Output 'Updated.'
}

export-modulemember -function UpdateFile 