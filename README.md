# tweek
Windows 10 Tweaking Framework


# Notes

Files pulled from raw.githubusercontent.com are UNIX line endings (LF not
CRLF); therefore when hashing ensure that the files are saved with a UNIX
style otherwise hashes will fail when the scripts are downloaded from git.

By default, group policy modifications are included and require the
GroupPolicy powershell module provided by the PolicyFileEditor module. These
can be install manually via the following commands (or tweek can do it itself
with the -InstallGroupPolicy option).

```powershell
Install-PackageProvider -Name NuGet -Force
  Install-Module PolicyFileEditor -Force
```

PolicyFileEditor (Module): https://www.powershellgallery.com/packages/PolicyFileEditor/2.0.2

NuGet (Module): https://www.powershellgallery.com/packages/NuGet/1.3.3