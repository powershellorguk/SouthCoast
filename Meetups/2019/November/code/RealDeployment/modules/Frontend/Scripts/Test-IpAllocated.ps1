[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]
    $ResourceGroup,

    [Parameter(Mandatory)]
    [string]
    $TenantId,

    [Parameter(Mandatory)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory)]
    [string]
    $ClientId,

    [Parameter(Mandatory)]
    [string]
    $ClientSecret
)

try {
    Import-Module Az.Network, Az.Accounts
    Disable-AzContextAutosave -Scope Process | Out-Null
    $InformationPreference = "Continue"

    $cred = [System.Management.Automation.PSCredential]::new($ClientId, (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
    Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -Credential $cred -ServicePrincipal  | Out-Null
    Write-Information "Connected to Azure..."

    Write-Information "Starting checks..."
    $startTime = Get-Date
    $publicIps = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroup
    $checkResult = @{}
    foreach ($publicIp in $publicIps) {
        $checkResult.Add($publicIp.Name, $false)
    }

    while ($true)
    {
        foreach ($publicIp in $publicIps) {
            if ($checkResult[$publicIp.Name] -eq $true) {
                Continue
            }
            Write-Information "Checking $($publicIp.Name)..."
            $ip = Get-AzPublicIpAddress -Name $publicIp.Name -ResourceGroupName $ResourceGroup
            if ($ip.ipconfiguration) {
                $checkResult[$publicIp.Name] = $true
                Write-Information "$($publicIp.Name) allocated..."
            }
        }

        $loopCheck = @($checkResult.Values | Group-Object)
        if ($loopCheck.Count -eq 1) {
            if ($loopCheck.Name -eq "True") {
                Write-Information "All Public IPs are now allocated..."
                break
            }
        }

        if ($startTime.AddMinutes(5) -gt (Get-Date)) {
            Write-Information "Not all Public IPs are allocated...sleeping..."
            Start-Sleep -Seconds 10
        } else {
            Write-Information "Not all Public IPs are allocated...timeout reached..."
            ThrowError -ExceptionName "Loop Timeout" -ExceptionMessage "Timeout reached whilst waiting for allocation of Public IP" -ExceptionObject $ip
        }
    }
} catch {
    Write-Error $Error[0]
    exit 1
}
