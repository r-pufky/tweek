Using module '..\TweekModule.psm1'

class WindowsFetch : TweekModule {
  [string[]] $PolicyReferences = @(
    'http://www.thewindowsclub.com/disable-superfetch-prefetch-ssd',
    'https://usefulpcguide.com/18428/system-and-compressed-memory-high-cpu/',
    'https://answers.microsoft.com/en-us/windows/forum/windows_10-performance/system-and-compressed-memory-service-high-cpu/421c32bd-e65b-4339-9473-db775e50096a?page=21',
    'https://superuser.com/questions/1016152/100-ssd-activity-0-r-w-speed-system-hang-issue'
  )
  [string] $Description = (
    'Disable Windows fetching services.'
  )
  [string] $LongDescription = (
    'Every time  you run an application in your PC, a Prefetch file which ' +
    'contains information about the files loaded by the application is ' +
    'created by Windows operating system. The information in the Prefetch ' +
    'file is used for optimizing the loading time of the application in the ' +
    'next time that you run it. SuperFetch attempts to predict which ' +
    'applications you will launch next and preloads all of the necessary ' +
    'data into memory. Its prediction algorithm is superior and can predict ' +
    "which next 3 applications you will launch by what time in a day.`n`n" +
    'In short SuperFetch and Prefetch are Windows Storage Management ' +
    'technologies that provide fast access to data on traditional hard ' +
    'drives. On Solid State Drives they result in unnecessary write ' +
    'operations. Windows 7/8/10 therefore by default will automatically ' +
    'disable SuperFetch and Prefetch, once it detects an SSD on your system.' +
    "`n`nIf your system is being pegged at 100% CPU usage with System and " +
    'Compressed Memory process is the culprit; superfetch and prefecth ' +
    'is what is causing this.'
  )
  [string] $ManualDescription = (
    "*  win + r > regedit`n" +
    '   *  Key: HKEY_LOCAL_MACHINE:\SYSTEM\CurrentControlSet\Control\' +
    "Session Manager\Memory Management\PrefetchParameters`n" +
    "      *  DWORD: EnablePrefetcher = 0`n" +
    '   *  Key: HKEY_LOCAL_MACHINE:\SYSTEM\CurrentControlSet\Control\' +
    "Session Manager\Memory Management\PrefetchParameters`n" +
    "      *  DWORD: EnableSuperfetcher = 0`n" +
    "*  win + r > services.msc`n" +
    "   *  Select 'Superfetch (SysMain)'`n" +
    "      *  right-click > stop`n" +
    "      *  right-click > properties > disable`n"
  )
  [string] $Author = 'github.com/r-pufky/tweek'
  [TweakClass] $Class = [TweakClass]::optional
  [TweakCatagory] $Catagory = [TweakCatagory]::filesystem

  hidden [void] ServiceTweek() {
    $this.Service.Disable('SysMain')
  }

  hidden [void] RegistryTweek() {
    $this.Registry.UpdateKey('HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'DWORD', 0)
    $this.Registry.UpdateKey('HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableSuperfetcher', 'DWORD', 0)
  }
}

function Load() {
  return [WindowsFetch]::New()
}

Export-ModuleMember -Function Load