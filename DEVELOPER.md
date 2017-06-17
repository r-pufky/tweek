# Developer Notes

## General Styleguide

* All powershell commands are preferred to be on one line.
* 2 space indentation.
* Opening [{( are not newlined.
* Docstrings are *Required*. Please following existing formats. Hardwrap
  @80 characters.
* Vars in Docstrings: one line preferred. If multiline, newline, 4 space
  indent and wrap at 80 chars.
* Any unused options do not need to be filled out / created.

```Docstring
# One line descriptor of method
#
# Additional information pertaining to method and how it works.
#
# Args:
#   [variable]: [Datatype] short description of variable and what it's for.
#   [variable]:
#       [Datatype] more than 80 character description of variable and/or how
#       the data is structured or used.
#
# Returns:
#   [Datatype] short description of what is returned.
#
# Raises:
#   [Exception] short description of why it's raised.
#
```

```Docstring
# One line descriptor of class
#
# Additional information pertaining to class and how it works.
#
# Properties:
#   [property]: [datatype] short description of property.
#   [property]:
#       [Datatype] more than 80 character description of variable and/or how
#       the data is structured or used.
#
```

## New Modules

* Url's for references can be on one line (violating 80 char limit)
* Description/LongDescription - hard wrap @80chars.
* URL DOC: one line per url
* Keep specific interfaces executing in specific methods. This will prevent
  issues in the future if specific interfaces can be disabled.
* Use Interfaces instead of directly accessing powershell functions. This
  is because these interfaces specifically log what is going on so the end
  user can log it and determine pre and post modification changes.
* Name your module appropriately, closest to the service or change that is
  happening.
* Overloaded methods that have the same parameters and return values as the
  original method do not need new docstrings.
* Files pulled from raw.githubusercontent.com are UNIX line endings (LF not
  CRLF); therefore when hashing ensure that the files are saved with a UNIX
  style otherwise hashes will fail when the scripts are downloaded from
  git.

## How to Write a New Module

* The easiest way is to copy an existing module and work with that version;
  otherwise ensure that file is saved as UNIX (LF not CRLF). Because of how
  git serves files, these will be LF even if they are saved as CRLF, which
  causes validation issues with file hashes on files that are downloaded.

### Determine module name

* The module name should be as close to the actual item that the tweek
  modifies as possible - the service name, program or registry key, etc.
* Ensure that the new module creates a class in this name *and* the Load()
  function is updated to use that new class name as well.
* The classname should match the filename of the module.
* TweekModule.psm1 should be import using the 'Using' clause.

```powershell
class MyNewModule : TweekModule {
}

function Load() {
  return [MyNewModule]::New()
}
```

### Fill out Description information
* All 'valid' modules require all descriptions and references to be filled out.
* Only 'valid' modules are executed.
* PolicyReferences should contain as many links as needed to justify the tweek
  and how it applies. It should not be self-referencing.
* ManualDescription contains the steps needed to apply the tweek manually; in
  markdown format. See other modules for the specific style.
* Author can be your email address, github info, or any other way to contact
  you.

 ```powershell
 ...
   [string[]] $PolicyReferences = @(
    'https://link/to/canonical/information/pertaining/to/tweek',
    'Another string reference to the tweak'
  )
  [string] $Description = (
    'Short one line description of tweek.'
  )
  [string] $LongDescription = (
    'A long description is multiple lines and explains in depth what the ' +
    'default windows state is and how the tweek modifies that state. Use ' +
    'as much information as needed here to convey what the tweek does.'
  )
  [string] $ManualDescription = (
    "*  win + r > gpedit.msc`n" +
    "   *  Key: Computer Configuration > Administrative Templates > " +
    "Windows Components > OneDrive`n" +
    "   *  Policy: Prevent the usage of OneDrive for file storage = " +
    "Enabled`n" +
    "*  start > Task Scheduler > Task Scheduler Library`n" +
    "   *  Key: OneDrive Standalone Update Task v2 = Disabled`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
```

### Fill out Tweek qualifiers and filters
* These define what the tweek is to the framework. These should be accurate.
* WindowsEdition defines what editions of windows this tweek does *not* apply
  to. See TweekModule for enums and details.
* WindowsVersion defines what versions of windows this tweek does *not* apply
  to. See TweekModule for enums and details.
* Class defines whether the module is stable, unstable or optional. Only
  stable modules are executed by default.
* Catagory defines a broad catagory for the tweek and how it affects the
  system. If multiple catagories exist, choose the one that is the largest or
  primary catagory.

```powershell
  [WindowsEdition[]] $EditionList = @(
    WindowsEdition::Microsoft_Windows_10_Mobile_Enterprise,
    WindowsEdition::Microsoft_Windows_10_Home
  )
  [WindowsVersion[]] $VersionList = @(
    WindowsVersion::v1607
  )
  [TweakClass] $Class = [TweakClass]::stable
  [TweakCatagory] $Catagory = [TweakCatagory]::services
```

### Write your Tweek
* The TweekModule base class provides interfaces to use for common things that
  you need to manipulate for Windows tweeking.
* Use the Interfaces to tweek. These will log their actions to the screen,
  which is a core tenant of this framework -- telling the user what is going
  on and essentially providing a log to reverse that.
* All options are avaliable (including windows version) to help make decisions
  when implementing a tweek.
* Tweeks should apply the change to **ALL** avaliable systems -- meaning if it
  is a tweek that can be done in Group Policy and the Registry, you should do
  it in both -- this will cover the largest amount of windows installations;
  and generally make your tweak more viable.
* If you need more functionality in Interfaces expand on existing ones or write
  a new one using the same style as previous ones.
* Keep interactions separated by the interface that a tweek uses. This enables
  the ability for the framework to enable or run specific parts of a tweek
  (e.g. if group policy can't be modified it won't disable the whole tweek).
* Look at Interfaces to see specific methods and how to use them.

```powershell
  hidden [void] GroupPolicyTweek() {
    # Tweek applies to home and pro, but home has no group policy.
    if (!$this.VersionList -Contains $this._WindowsVersion) {
      $this.GroupPolicy.Update('Machine', 'My\Awesome\Policy', 'PolicyName', 'DWORD', 1)
    }
  }

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKCU:\SOFTWARE\Something', 'SomeKey', 'DWORD', 0)
    # We can even enumerate keys and take actions on them.
    $Apps = $this.Registry.EnumerateKey('HKCU:\SOFTWARE\Something')
    foreach ($App in $SuggestedApps.GetEnumerator()) {
      $this.Registry.UpdateKey('HKCU:\Software\Something', $App.Name, $App.Value[0], 0)
    }
  }

  hidden [void] ServiceTweek() {
    $this.Service.Disable('Some Service Name')
  }

  hidden [void] ScheduledTaskTweek() {
    $this.ScheduledTask.Disable('Some stupid scheduled task name')
  }

  hidden [void] FileTweek() {
    $this.File.AppendIfNew('c:\somefile.txt', 'ASCII', 'Some new data')
  }
```

## Testing
* Be sure to use the -Unsigned option to not validate hashes from the server
* The -Testing flag is **only** used to inject testing modules for interface
  testing, it is not used for testing normal modules.
* Ensure that the tweek works, including the help menus.
* When ready, use Get-Filehash <module> to generate the hash. Update the local
  integrity-hashes.sha256 file with your new module and hash. Include this in
  your CL. Be sure your file is UNIX (LF) formated, not WINDOWS (CRLF) 
  formatted.
