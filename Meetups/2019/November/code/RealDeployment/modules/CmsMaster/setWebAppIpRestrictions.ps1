[CmdletBinding()]

param (
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
    $ResourceGroup,

    [Parameter(Mandatory)]
    [string]
    $WebApp,

    [Parameter()]
    [string]
    $SlotName,

    [Parameter(Mandatory)]
    [string]
    $IPWhitelist
)

$InformationPreference = "Continue"
$apiVersion     = "2018-02-01"

try
{
    Import-Module Az.Accounts, Az.Resources
    Disable-AzContextAutosave -Scope Process

    Write-Information -MessageData "Connecting to Azure..."
    $secureSecret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
    $credential = [System.Management.Automation.PSCredential]::new($ClientId,$secureSecret)
    Connect-AzAccount -ServicePrincipal -Subscription $SubscriptionId -Tenant $TenantId -Credential $credential | Out-Null

    Write-Information -MessageData "Checking for WebApp Slot..."
    if ($SlotName)
    {
        Write-Information -MessageData "Slot name specified... selecting slot-specific data"
        $resourceType   = "Microsoft.Web/sites/slots/config"
        $webAppName     = "$WebApp/$SlotName/web"
    }
    else
    {
        Write-Information -MessageData "Slot name not specified... selecting regular data"
        $resourceType   = "Microsoft.Web/sites/config"
        $webAppName     = "$WebApp/web"
    }

    Write-Information -MessageData "Setting WebApp IP Restrictions..."
    $webAppIpRestrictions = @()
    $ipList = $IPWhitelist -split ","

    foreach ($ip in $ipList)
    {
        if ($ip -notmatch "/") {$ip = "$ip/32"}

        $restriction = [PSCustomObject]@{
            ipAddress   = $ip
            action      = "Allow"
            tag         = "Default"
            priority    = (300 + $ipList.IndexOf($ip))
        }

        $webAppIpRestrictions += $restriction
    }

    $setParams = @{
        ResourceGroupName   = $resourceGroup
        ResourceType        = "$resourceType"
        ResourceName        = $webAppName
        ApiVersion          = $apiVersion
        PropertyObject      = (@{ipSecurityRestrictions = $webAppIpRestrictions})
        ErrorAction         = "Stop"
        Force               = $True
    }
    Set-AzResource @setParams | Out-Null
    Write-Information -MessageData "Successfully set WebApp IP Whitelist!"
}
catch
{
    $scriptError = $_.Exception
    $scriptError = $scriptError -split "\n"
    Write-Error "$scriptError"
    exit 1
}
