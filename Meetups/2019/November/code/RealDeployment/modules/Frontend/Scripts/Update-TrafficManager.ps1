[CmdletBinding()]

param(
    [Parameter(Mandatory)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory)]
    [string]
    $TenantId,

    [Parameter(Mandatory)]
    [string]
    $ClientId,

    [Parameter(Mandatory)]
    [string]
    $ClientSecret,

    [Parameter(Mandatory)]
    [string]
    $TrafficManagerProfile,

    [Parameter(Mandatory)]
    [string]
    $ProbeUrl,

    [Parameter()]
    [Int32]
    $MonitoringInterval = 10,

    [Parameter()]
    [Int32]
    $MonitoringTimeout = 5
)

try {
    $InformationPreference = "Continue"
    Disable-AzContextAutosave -Scope Process | Out-Null

    Write-Information "Connecting to Azure.."
    $credentials = [System.Management.Automation.PSCredential]::New($ClientId,(ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
    Connect-AzAccount -ServicePrincipal -Tenant $TenantId -Subscription $SubscriptionId -Credential $credentials

    $trafficManager = Get-AzTrafficManagerProfile -ResourceGroupName $ResourceGroupName -Name $TrafficManagerProfile
    $update = $false

    if ($trafficManager.CustomHeaders) {
        if ($trafficManager.CustomHeaders.Name -eq "host" -and $trafficManager.CustomHeaders.Value -eq $ProbeUrl) {
            Write-Information "Custom Header set to expected value..."
        } else {
            Write-Information "Custom Header present, but with incorrect values...resetting..."
            $update = $true
            $trafficManager.CustomHeaders = [PSCustomObject]@{
                Name    = "host"
                Value   = $ProbeUrl
            }
        }
    } else {
        Write-Information "Custom Header missing...setting..."
        $update = $true
        $trafficManager.CustomHeaders = [PSCustomObject]@{
            Name    = "host"
            Value   = $ProbeUrl
        }
    }

    if ($trafficManager.MonitorIntervalInSeconds -ne $MonitoringInterval) {
        Write-Information "Monitor Interval incorrect...resetting..."
        $trafficManager.MonitorIntervalInSeconds = $MonitoringInterval
        $update = $true
    }

    if ($trafficManager.MonitorTimeoutInSeconds -ne $MonitoringTimeout) {
        Write-Information "Monitor Timeout incorrect...resetting..."
        $trafficManager.MonitorTimeoutInSeconds = $MonitoringTimeout
        $update = $true
    }

    if ($update) {
        Set-AzTrafficManagerProfile -TrafficManagerProfile $trafficManager
        Write-Information "Traffic Manager Profile updated..."
    }
}
catch {
    Write-Output $error[0]
    exit 1
}
