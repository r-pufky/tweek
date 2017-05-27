# Dynamically load all powershell tweakmodules in modules\
# For these modules to be loaded, Unblock-File *??

foreach ($file in Get-ChildItem '.\modules\' -Filter '*.psm1') {
  Import-Module $file.FullName
  $class_name = ((Get-Module $file.BaseName).ImplementingAssembly.DefinedTypes | where IsPublic).Name
  $class_loader = (get-command 'Load' -CommandType Function -Module $class_name).ScriptBlock
  $temp = invoke-command -scriptblock $class_loader
  Write-Output ($temp)
  $temp.Validate()
  $temp.Name()
}
