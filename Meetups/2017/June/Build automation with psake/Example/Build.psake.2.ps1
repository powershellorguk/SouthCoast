Properties {
    $ModuleName    = (Get-Item -Path $PSScriptRoot).Name
    $BuildLocation = "$($env:TEMP)\$ModuleName"
    $DeployDir     = Join-Path -Path (Split-Path $profile.CurrentUserAllHosts -Parent) -ChildPath $ModuleName
}

Task default -depends BuildManifest, Setup, Analyze, Test, Clean

Task Setup -depends BuildManifest -requiredVariables BuildLocation {
    if (-not (Test-Path -Path $BuildLocation)) {
        New-Item -Path $BuildLocation -ItemType Directory -Verbose:$VerbosePreference | Out-Null
    }

    $Setup = @{
        Path        = "$PSScriptRoot\src\*"
        Destination = $BuildLocation
        Recurse     = $true
        Force       = $true
        Exclude     = ''
    }

    Copy-Item @Setup -Verbose:$VerbosePreference
}

Task BuildManifest {
    Write-Verbose -Message "Building manifest in $PSScriptRoot\Build.Manifest.ps1"
    . "$PSScriptRoot\Build.Manifest.ps1"
}

Task Analyze -depends Setup -requiredVariables BuildLocation {
    $analysisResult = Invoke-ScriptAnalyzer -Path $BuildLocation -Recurse -Verbose:$VerbosePreference

    if ($analysisResult) {
        $analysisResult | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors/warnings were found. Build cannot continue!'
    }
}

Task Test -depends Setup {
    $TestResult = Invoke-Pester -Path $PSScriptRoot\test -PassThru -Verbose:$VerbosePreference

    if ($TestResult.FailedCount -gt 0) {
        $TestResult | Format-List
        Write-Error -Message 'One or more Pester tests for the deployment failed. Build cannot continue!'
    }
}

Task Deploy -depends Setup, Analyze, Test -requiredVariables DeployDir, BuildLocation {
    if (-not (Test-Path -Path $DeployDir)) {
        Write-Verbose -Message 'Creating deployment directory'
        New-Item -Path $DeployDir -ItemType Directory -Verbose:$VerbosePreference | Out-Null
    }

    Copy-Item -Path "$BuildLocation\*" -Destination $DeployDir -Verbose:$VerbosePreference -Recurse -Force
}

Task Clean -requiredVariables BuildLocation {
    if (Test-Path -Path $BuildLocation) {
        Write-Verbose -Message 'Cleaning build directory'
        Remove-Item -Path $BuildLocation -Recurse -Force -Verbose:$VerbosePreference
    }
}

Task ? -alias 'Help' -description 'List the available tasks' -preaction { Write-Host 'Help is on the way!'; $global:1 = $false } -precondition { $1 -eq $null } {
    Write-Output 'Available tasks:'
    Write-Output $PSake.Context.Peek().Tasks.Keys | Sort-Object
}