#requires -RunAsAdministrator
#requires -Version 5

## Install the NuGet provider required by PowerShellGet
if (-not (Get-PackageProvider -Name NuGet -ListAvailable)) {
    Install-PackageProvider -Name NuGet -ForceBootstrap -Force -ErrorAction Stop -Verbose
}

## Install required modules from the PowerShell Gallery
foreach ($module in 'xNetworking', 'xWinEventLog', 'xWebAdministration', 'PSDscResources', 'PolicyFileEditor') {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Install-Module -Name $module -Force -ErrorAction Stop -Verbose
    }
}
