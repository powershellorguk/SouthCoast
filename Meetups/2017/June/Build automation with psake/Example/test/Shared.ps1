$ModuleManifestName  = "$((Get-Item -Path "$PSScriptRoot\..").Name).psd1"
$ModuleManifestPath  = "$PSScriptRoot\..\src\$ModuleManifestName"
$ModuleRoot = (Get-Item -Path "$PSScriptRoot\..").FullName
$ModuleName = (Get-Item -Path "$PSScriptRoot\..").Name

if (-not $SuppressImportModule) {
    # -Scope Global is needed when running tests from inside of psake, otherwise
    # the module's functions cannot be found in the Plaster\ namespace
    Import-Module $ModuleManifestPath -Scope Global
}