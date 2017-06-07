# test module for file workings
#
# uses tests registry locations.

Using module '..\TweekModule.psm1'

class FileTweekTest : TweekModule {
  [WindowsEdition] $Edition = [WindowsEdition]::pro
  [string[]] $PolicyReferences = @('https://some.shit')
  [string] $Description = 'Tests file tweaks.'
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClassification] $Classification = [TweakClassification]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::filesystem

  hidden [void] FileTweek() {
    $TestFile = '.\filetest.txt'
    $FirstData = 'this is a line of text for a file.'
    $SecondData = 'Another line'
    $this.File.AppendToFile($TestFile, 'ASCII', $FirstData)
    $this.File.AppendIfNew($TestFile, 'ASCII', $SecondData)
    $this.File.AppendIfNew($TestFile, 'ASCII', $SecondData)
    $this.File.FindAndReplace($TestFile, $FirstData, $SecondData)
    $this.File.ClearFile($TestFile)
    $this.File.DeleteFile($TestFile)
  }

  hidden [void] ExecuteOrDryRun([switch]$DryRun, [switch]$Testing) { $this.ApplyTweak() }
}

function Load() {
  return [FileTweekTest]::New()
}

Export-ModuleMember -Function Load