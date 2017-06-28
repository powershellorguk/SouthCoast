[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$SuppressImportModule = $false
. $PSScriptRoot\Shared.ps1

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath
        $? | Should Be $true
    }

    It 'Has a description' {
        (Test-ModuleManifest -Path $ModuleManifestPath).Description | Should Not Be $null
    }

    It 'Has release notes' {
        (Test-ModuleManifest -Path $ModuleManifestPath).ReleaseNotes | Should Not Be $null
    }

    It 'Has a version' {
        (Test-ModuleManifest -Path $ModuleManifestPath).Version | Should Not Be $null
    }
}