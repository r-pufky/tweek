# Provides interface to Filesystem for Tweek Modules.
#

class TweekFileInterface {
  [string[]]$EncodingValues = @('UNKNOWN', 'STRING', 'UNICODE', 'BIGENDIANUNICODE', 'UTF8', 'UTF7', 'UTF32', 'ASCII', 'DEFAULT', 'OEM', 'BIGENDIANUTF32', 'BYTE')
  $_VerbosePreference

  [void] ClearFile([string]$Path) {
    # Clears specified file of contents.
    #
    # Args:
    #   Path: String path of file to clear.
    #
    Write-Host ('    Clearing contents of file: ' + $Path)
    Clear-Content $Path
  }

  [void] DeleteFile([string]$Path) {
    # Deletes a specified file.
    #
    # Args:
    #   Path: String path of file to delete.
    #
    Write-Host ('    Deleting file: ' + $Path)
    Remove-Item $Path
  }

  [void] FindAndReplace([string]$Path, [string]$Search, [string]$Replace) {
    # Replace a specific line in a given file.
    #
    # Args:
    #   Path: String path of file to delete.
    #   Search: String to find (for replacement).
    #   Replace: String to be used for replacement.
    #
    Write-Host ('    ' + $Path + ': Searching: [' + $Search + '] => Replace: [' + $Replace + ']')
    (Get-Content $Path).replace($Search, $Replace) | Set-Content $Path
  }

  [void] AppendToFile([string]$Path, [string]$Encoding, [String]$Data) {
    # Appends given data to a file.
    #
    # This will *NOT* insert a newline by default.
    #
    # Args:
    #   Path: String path of file to append.
    #   Encoding: String encoding to use for file. Generally ASCII.
    #   Data: String data to write to file.
    #
    if (!($this.EncodingValues -contains $Encoding)) {
      throw [System.ArgumentOutOfRangeException]::New('AppendToFile requires Encoding to be a specific value  [' + $this.EncodingValues + '], not: ' + $Encoding)
    }
    Write-Host ('    Appending to file: ' + $Path + ' (' + $Encoding + ') => Data: [' + $Data + ']')
    Add-Content -Path $Path -Encoding $Encoding -Value $Data
  }

  [void] AppendIfNew([string]$Path, [string]$Encoding, [String]$Data) {
    # Appends given data to a file if that data does not exist yet.
    #
    # This will *NOT* insert a newline by default.
    #
    # Args:
    #   Path: String path of file to append.
    #   Encoding: String encoding to use for file. Generally ASCII.
    #   Data: String data to write to file.
    #
    if (!($this.EncodingValues -contains $Encoding)) {
      throw [System.ArgumentOutOfRangeException]::New('AppendIfNew requires Encoding to be a specific value  [' + $this.EncodingValues + '], not: ' + $Encoding)
    }
    if (-Not (Select-String -Path $Path -Pattern $Data)) {
      $this.AppendToFile($Path, $Encoding, $Data)
    } else {
      Write-Host ('    Appending ignore, data already exists in file: ' + $Path + ' (' + $Encoding + ') => Data: [' + $Data + ']')
    }
  }
}
