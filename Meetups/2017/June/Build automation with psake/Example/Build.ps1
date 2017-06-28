#Requires -Module psake, Pester, PsScriptAnalyzer
[CmdletBinding()]

Param (
    [Parameter()]
    [string[]]
    $Task = 'build',

    [Parameter()]
    [System.Collections.Hashtable]
    $Parameters
)

$psake = @{
    buildFile  = "$PSScriptRoot\Build.psake.ps1"
    taskList   = $Task
    Verbose    = $VerbosePreference
}

if ($Parameters) {
    $psake.parameters = $Parameters
}

. $PSScriptRoot\Build.manifest.ps1
Invoke-psake @psake