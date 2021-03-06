﻿# test module for file workings
#
# uses tests registry locations.

Using module '..\TweekModule.psm1'

class FileTweekTest : TweekModule {
  [WindowsEdition[]] $EditionList = @(
    [WindowsEdition]::Microsoft_Windows_10_Pro
  )
  [string[]] $PolicyReferences = @('https://some.shit')
  [string] $Description = 'Tests file tweaks.'
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::filesystem

  hidden [void] FileTweek() {
    $TestFile = '.\filetest.txt'
    $FirstData = 'this is a line of text for a file.'
    $SecondData = 'Another line'
    $this.File.Append($TestFile, 'ASCII', $FirstData)
    $this.File.AppendIfNew($TestFile, 'ASCII', $SecondData)
    $this.File.AppendIfNew($TestFile, 'ASCII', $SecondData)
    $this.File.FindAndReplace($TestFile, $FirstData, $SecondData)
    $this.File.Clear($TestFile)
    $this.File.Delete($TestFile)
  }

  hidden [void] ExecuteOrDryRun() { $this.ApplyTweak() }
}

function Load() {
  return [FileTweekTest]::New()
}

Export-ModuleMember -Function Load