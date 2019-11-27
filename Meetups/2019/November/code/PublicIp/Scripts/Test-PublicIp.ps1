[CmdletBinding()]

param (
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
    $ClientSecret,

    [Parameter(Mandatory)]
    [string]
    $PublicIp
)

function Test-IpAllocation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $PublicIp,

        [Parameter()]
        [UInt32]
        $Timeout = 5
    )

    process {
        $allocated = $false
        $start = Get-Date
        while (!$allocated) {
            $ip = (Get-AzPublicIpAddress -Name $PublicIp).IpAddress
            if ($ip -ne "Not Assigned") {
                $allocated = $true
            } elseif ($start.AddMinutes($Timeout) -gt (Get-Date)) {
                Start-Sleep -Seconds 10
            } else {
                break
            }
        }
        if (!$allocated) {
            Write-Information "Function terminated due to timeout" -InformationAction Continue
            Write-Output $false
        } else {
            Write-Output $true
        }
    }
}

try {
    $credentials = [System.Management.Automation.PSCredential]::new($ClientId,(ConvertTo-SecureString $ClientSecret -AsPlainText -Force))

    Disable-AzContextAutosave -Scope process | Out-Null
    Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -Credential $credentials -ServicePrincipal | Out-Null

    Test-IpAllocation -PublicIp $PublicIp
} catch {
    Write-Error $error[0]
    exit 1
}
