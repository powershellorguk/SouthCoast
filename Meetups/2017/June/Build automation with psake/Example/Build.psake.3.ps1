Properties {
    $ModuleName    = (Get-Item -Path $PSScriptRoot).Name
    $BuildLocation = "$($env:TEMP)\$ModuleName"
    $DeployDir     = Join-Path -Path (Split-Path $profile.CurrentUserAllHosts -Parent) -ChildPath $ModuleName

    # If you specify the certificate subject when running a build that certificate
    # must exist in the users personal certificate store. The build will import the
    # certificate (if required).

    # PFX certificates for import are supported in an interactive scenario only,
    # as a way to import a certificate into the user personal store for later use.
    # This can be provided using the CertPfxPath parameter.
    # PFX passwords will not be stored.
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

Task Analyze -depends Setup -requiredVariables BuildLocation{
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

Task Sign -depends Analyze, Test -requiredVariables BuildLocation {
    if ($CertPfxPath) {
        $CertImport = @{
            CertStoreLocation = 'Cert:\CurrentUser\My'
            FilePath          = $CertPfxPath
            Password          = $(Get-Credential -Message 'Enter the PFX password to import the certificate').Password
            ErrorAction       = 'Stop'
        }

        Write-Verbose -Message "Importing PFX certificate from $CertPfxPath"
        $Cert = Import-PfxCertificate @CertImport -Verbose:$VerbosePreference
    }

    else {
        Write-Verbose -Message 'No stored certificate subject, asking user'
        $CertSubject = 'CN='
        $CertSubject += Read-Host -Prompt 'Enter the certificate subject you wish to use (CN= prefix will be added)'

        $Cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert |
            Where-Object { $_.Subject -eq $CertSubject -and $_.NotAfter -gt (Get-Date) } |
            Sort-Object -Property NotAfter -Descending | Select-Object -First 1
    }

    if ($Cert) {
        $Authenticode = @{
            FilePath    = @(Get-ChildItem -Path "$BuildLocation\*" -Recurse -Include '*.ps1', '*.psm1')
            Certificate = Get-ChildItem Cert:\CurrentUser\My |
                Where-Object { $_.Thumbprint -eq $Cert.Thumbprint }
        }

        Write-Output -InputObject $Authenticode.FilePath | Out-Default
        Write-Output -InputObject $Authenticode.Certificate | Out-Default
        $SignResult = Set-AuthenticodeSignature @Authenticode -Verbose:$VerbosePreference
        # Write-Output $SignResult

        if ($SignResult.Status -ne 'Valid') {
            throw "Signing one or more scripts failed."
        }
    }

    else {
        throw 'No valid certificate subject supplied.'
    }
}

Task Deploy -depends Setup, Analyze, Test -requiredVariables BuildLocation, DeployDir {
    if (-not (Test-Path -Path $DeployDir)) {
        Write-Verbose -Message 'Creating deployment directory'
        New-Item -Path $DeployDir -ItemType Directory -Verbose:$VerbosePreference | Out-Null
    }

    Copy-Item -Path "$BuildLocation\*" -Destination $DeployDir -Verbose:$VerbosePreference -Recurse -Force
}

Task DeploySigned -depends Sign, Deploy {}

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