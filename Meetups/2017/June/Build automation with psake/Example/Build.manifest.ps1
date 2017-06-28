<#
    Name  : Build Manifest
    Author: David Green
#>

$ModuleName  = "$((Get-Item -Path "$PSScriptRoot").Name)"
$ModuleRoot  = "$PSScriptRoot\src\$ModuleName.psm1"

# Removes all versions of the module from the session before importing
Get-Module $ModuleName | Remove-Module

$Module   = Import-Module $ModuleRoot -PassThru -ErrorAction Stop
$ModuleCommands = Get-Command -Module $Module

$ModuleDescription = @{
    Path              = "$PSScriptRoot\src\$ModuleName.psd1"
    Description       = 'A PowerShell script module designed to get and set the timezone, wrapping the tzutil command.'
    RootModule        = "$ModuleName.psm1"
    Author            = 'David Green'
    CompanyName       = 'http://tookitaway.co.uk/, https://github.com/davegreen/PowerShell/'
    Copyright         = '(c) 2016 David Green. All rights reserved.'
    PowerShellVersion = '4.0'
    ModuleVersion     = '1.2.4'
    FileList           = (Get-ChildItem -Recurse -File -Path "$PSScriptRoot\src").Name
    AliasesToExport    = $ModuleCommands.Name -Like '*-*'
    CmdletsToExport    = $ModuleCommands.Name -Like '*-*'
    FunctionsToExport  = $ModuleCommands.Name -Like '*-*'
    #VariablesToExport = ''
    #RequiredModules   = ''
    #Tags              = @('')
    #LicenseUri        = ''
    #ProjectUri        = ''
    #IconUri           = ''
    ReleaseNotes       = 'Example Module Release Notes'
}

if (Test-Path -Path $ModuleDescription.Path) {
    Update-ModuleManifest @ModuleDescription
}
else {
    New-ModuleManifest @ModuleDescription
}

Get-Module $ModuleName | Remove-Module