Properties {
    $ModuleName    = (Get-Item -Path $PSScriptRoot).Name
    $BuildLocation = "$($env:TEMP)\$ModuleName"
    $DeployDir     = Join-Path -Path (Split-Path $profile.CurrentUserAllHosts -Parent) -ChildPath $ModuleName
}

Task default -depends Setup, Clean

Task Setup -requiredVariables BuildLocation {
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

Task Deploy -depends Setup -requiredVariables DeployDir, BuildLocation {
    if (-not (Test-Path -Path $DeployDir)) {
        Write-Verbose -Message 'Creating deployment directory'
        New-Item -Path $DeployDir -ItemType Directory -Verbose:$VerbosePreference | Out-Null
    }

    Copy-Item -Path "$BuildLocation\*" -Destination $DeployDir -Verbose:$VerbosePreference -Recurse -Force
}

Task ShowProperties {
    Write-Output $PSake.Context.Peek().Properties
    Write-Output "Overriden Buildlocation: $BuildLocation"
}

Task Clean -requiredVariables BuildLocation {
    if (Test-Path -Path $BuildLocation) {
        Write-Verbose -Message 'Cleaning build directory'
        Remove-Item -Path $BuildLocation -Recurse -Force -Verbose:$VerbosePreference
    }
}

Task ? -alias 'Help' -description 'List the available tasks' {
    Write-Output 'Available tasks:'
    Write-Output $PSake.Context.Peek().Tasks.Keys | Sort-Object
}