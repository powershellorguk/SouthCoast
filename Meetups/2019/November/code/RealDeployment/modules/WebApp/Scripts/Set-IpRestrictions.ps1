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
    $WhiteList,

    [Parameter()]
    [switch]
    $Master
)

try {
    $InformationPreference = "Continue"

    Import-Module Az.Accounts, Az.Resources
    Disable-AzContextAutosave -Scope Process | Out-Null

    $creds = [System.Management.Automation.PSCredential]::new($ClientId, (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
    Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -Credential $creds -ServicePrincipal | Out-Null
    Write-Information "Connected to Azure..."

    if ($Master) {
        Write-Information "Processing Content Mastering WebApp only..."
        $webApps = (Get-AzWebApp -ResourceGroupName $ResourceGroup).Where({$_.Name -like "*-Master"}).Name
    } else {
        Write-Information "Processing Server Farm WebApps..."
        $webApps = (Get-AzWebApp -ResourceGroupName $ResourceGroup).Where({$_.Name -notlike "*-Master"}).Name
    }

    Write-Information "Processing IP White List..."
    $ipRestrictions = @()
    $ipList = $WhiteList -split ","
    foreach ($ip in $ipList) {
        if ($ip -notmatch "/") {
            $ipList[$ipList.IndexOf($ip)] = "$ip/32"
            $ip = "$ip/32"
        }
        $restriction = [PSCustomObject]@{
            ipAddress   = $ip
            action      = "Allow"
            tag         = "Default"
            priority    = (300 + $ipList.IndexOf($ip))
        }
        $ipRestrictions += $restriction
    }

    foreach ($webApp in $webApps) {
        Write-Information "Processing $webApp..."
        $props = @{
            ipSecurityRestrictions = $ipRestrictions
            ScmIpSecurityRestrictionsUseMain = "true"
        }
        $setParams = @{
            ResourceGroupName   = $ResourceGroup
            ResourceType        = "Microsoft.Web/sites/config"
            ResourceName        = "$webApp/web"
            ApiVersion          = "2018-02-01"
            PropertyObject      = $props
            ErrorAction         = "Stop"
            Force               = $true
        }
        Set-AzResource @setParams | Out-Null
        Write-Information "IP restrictions updated on $webApp..."

        $slots = Get-AzWebAppSlot -ResourceGroupName $ResourceGroup -Name $webApp
        if ($slots) {
            Write-Information "Slot(s) found on $webApp..."
            foreach ($slot in $slots) {
                Write-Information "Processing $($slot.Name)..."
                $setParams = @{
                    ResourceGroupName   = $ResourceGroup
                    ResourceType        = "Microsoft.Web/sites/slots/config"
                    ResourceName        = "$($slot.Name)/web"
                    ApiVersion          = "2018-02-01"
                    PropertyObject      = $props
                    ErrorAction         = "Stop"
                    Force               = $true
                }
                Set-AzResource @setParams | Out-Null
                Write-Information "IP restrictions updated on $($slot.Name)..."
            }
        }
    }
    Write-Information "Processed all WebApps and Slots...done"
} catch {
    Write-Error $Error[0]
    exit 1
}
