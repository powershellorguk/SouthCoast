[CmdletBinding()]

param (
    [Parameter(Mandatory = $true)]
    [string]
    $TenantId,

    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]
    $ClientId,

    [Parameter(Mandatory = $true)]
    [string]
    $ClientSecret,

    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]
    $IpWhitelist
)

try {
    Disable-AzContextAutosave -Scope Process | Out-Null
    $InformationPreference = "Continue"

    $creds = [System.Management.Automation.PSCredential]::new($ClientId, (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
    Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -Credential $creds -ServicePrincipal | Out-Null
    Write-Information "Connected to Azure..."

    $ipList = $IpWhitelist.split(",")

    $sqlServers = Get-AzSqlServer -ResourceGroupName $ResourceGroup

    foreach ($server in $sqlServers) {
        Write-Information "Processing $($server.ServerName)..."
        foreach ($ip  in $ipList) {
            Write-Information "Setting rule for $ip..."
            $params = @{
                ResourceGroupName   = $ResourceGroup
                ServerName          = $server.ServerName
                FirewallRuleName    = "RuleAllowIp_$ip"
                StartIpAddress      = $ip
                EndIpAddress        = $ip
            }
            New-AzSqlServerFirewallRule @params | Out-Null
        }
        Write-Information "Finished processing $($server.ServerName)..."
    }
    Write-Information "All servers processed...done"
} catch {
    Write-Error $Error[0]
    exit 1
}
