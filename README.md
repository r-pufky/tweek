# tweek
Windows 10 Tweaking Framework


# Notes

Files pulled from raw.githubusercontent.com are UNIX line endings (LF not
CRLF); therefore when hashing ensure that the files are saved with a UNIX
style otherwise hashes will fail when the scripts are downloaded from git.

GroupPolicy powershell module is not included by default. You need to
install Windows 10 Remote Server Administration tools to import this
module. The script will still execute, but will disable GPO modifications
if GPO module is not installed.

https://www.microsoft.com/en-us/download/details.aspx?id=45520