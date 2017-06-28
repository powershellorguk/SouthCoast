# https://kevinmarquette.github.io/2017-01-21-powershell-module-continious-delivery-pipeline/?utm_source=blog&utm_medium=blog&utm_content=titlelink
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$SuppressImportModule = $true
. $PSScriptRoot\Shared.ps1

Describe "General project validation: $ModuleName" {
    $Scripts = Get-ChildItem $ModuleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

    # TestCases are splatted to the script so we need hashtables
    $testCase = $Scripts | Foreach-Object { @{ File = $_ } }
    It "Script <file> should be valid powershell" -TestCases $testCase {
        Param ($File)

        $File.fullname | Should Exist
        $Contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $Errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($Contents, [ref]$Errors)
        $Errors.Count | Should Be 0
    }

    It "Module '$ModuleName' can import cleanly" {
        { Import-Module $ModuleManifestPath -Force } | Should Not Throw
    }
}