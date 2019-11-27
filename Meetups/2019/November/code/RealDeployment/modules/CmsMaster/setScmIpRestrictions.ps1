[CmdletBinding()]

param (
    [Parameter(Mandatory)]
    [string]
    $WebAppId,

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
    $ClientSecret
)

$InformationPreference = "Continue"

try
{
    Import-Module Az.Accounts, Az.Resources
    Disable-AzContextAutosave -Scope Process

    Write-Information -MessageData "Connecting to Azure..."
    $secureSecret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
    $credential = [System.Management.Automation.PSCredential]::new($ClientId,$secureSecret)
    Connect-AzAccount -ServicePrincipal -Subscription $SubscriptionId -Tenant $TenantId -Credential $credential | Out-Null

    Write-Information -MessageData "Checking `$WebAppId is valid..."
    $webApp = Get-AzResource -ResourceId $WebAppId

    Write-Information -MessageData "Updating SCM IP Restrictions..."
    $params = @{
        ResourceGroupName   = $webApp.ResourceGroupName
        ResourceType        = "Microsoft.Web/sites/config"
        ResourceName        = "$($webApp.Name)/web"
        ApiVersion          = "2018-02-01"
        PropertyObject      = (@{scmIpSecurityRestrictionsUseMain = "true"})
        ErrorAction         = "Stop"
        Force               = $True
    }
    Set-AzResource @params | Out-Null

    Write-Information -MessageData "Successfully set SCM app to use Main app's IP Whitelist!"
}
catch
{
    $scriptError = $_.Exception
    $scriptError = $scriptError -split "\n"
    Write-Error "$scriptError"
    exit 1
}
