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
    [alias("VirtualPath")]
    [string]
    $Path,

    [Parameter(Mandatory)]
    [alias("JobName")]
    [string]
    $Name
)

$InformationPreference = "Continue"
$apiVersion = "2018-02-01"

Import-Module Az.Accounts, Az.Resources -Verbose:$false

try {
    Disable-AzContextAutosave -Scope Process

    Write-Information -MessageData "Connecting to Azure..."
    Write-Verbose -Message "Connecting using:"
    Write-Verbose -Message "Subscription: $SubscriptionId"
    Write-Verbose -Message "Tenant: $TenantId"
    Write-Verbose -Message "Client ID: $ClientId"
    Write-Verbose -Message "Client Secret: ...$($ClientSecret.Substring($ClientSecret.Length - 4))"
    $secureSecret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
    $credential = [System.Management.Automation.PSCredential]::new($ClientId, $secureSecret)
    Connect-AzAccount -ServicePrincipal -Subscription $SubscriptionId -Tenant $TenantId -Credential $credential | Out-Null

    Write-Information -MessageData "Checking for WebApp Slot..."
    Write-Verbose -Message "Slot name being checked: $SlotName"
    Write-Verbose -Message "Resource Group: $ResourceGroup"
    Write-Verbose -Message "Web App: $WebApp"
    if ($SlotName) {
        Write-Information -MessageData "Slot name specified... selecting slot-specific data"
        $resourceType = "Microsoft.Web/sites/slots/config"
        $webAppName = "$((Get-AzResource -ResourceGroupName $ResourceGroup | Where-Object {$_.Name -eq "$WebApp/$SlotName"}).Name)/web"
    } else {
        Write-Information -MessageData "Slot name not specified... selecting regular data"
        $resourceType = "Microsoft.Web/sites/config"
        $webAppName = "$((Get-AzResource -ResourceGroupName $ResourceGroup -Name $WebApp).Name)/web"
    }

    Write-Information -MessageData "Collect existing info from WebApp..."
    Write-Verbose -Message "Web App Configuration Parameters"
    Write-Verbose -Message "Name: $webAppName"
    Write-Verbose -Message "ResourceType: $resourceType"
    Write-Verbose -Message "ResourceGroupName: $ResourceGroup"
    Write-Verbose -Message "ApiVersion: $apiVersion"
    $webAppConfigParams = @{
        Name              = $webAppName
        ResourceType      = $resourceType
        ResourceGroupName = $ResourceGroup
        ApiVersion        = $apiVersion
    }
    $webAppSettings = Get-AzResource @webAppConfigParams

    Write-Information -MessageData "Updating WebApp Virtual Applications..."
    $webAppVirtualApp = $webAppSettings.Properties.virtualApplications
    Write-Verbose -Message "Number of pre-existing virtual applications: $($webAppVirtualApp.count)"

    if ($webAppVirtualApp.virtualPath.IndexOf($Path) -lt 0) {
        Write-Verbose -Message "Virtual application specified not found on Web App"
        Write-Verbose -Message "Virtual application deployment details"
        Write-Verbose -Message "Virtual Path: $Path"
        Write-Verbose -Message "Physical Path: site\wwwroot\App_Data\jobs\triggered\$Name"
        Write-Verbose -Message "Preload Enabled: false"
        Write-Verbose -Message "Virtual Directories: null"
        $VdSetting = [PSCustomObject]@{
            virtualPath        = $Path
            physicalPath       = "site\wwwroot\App_Data\jobs\triggered\$Name"
            preloadEnabled     = "false"
            virtualDirectories = "null"
        }
        $webAppVirtualApp += $VdSetting
        Write-Verbose -Message "Number of virtual applications to be saved to Web App: $($webAppVirtualApp.count)"

        $setParams = @{
            ResourceGroupName = $resourceGroup
            ResourceType      = $resourceType
            ResourceName      = $webAppName
            ApiVersion        = $apiVersion
            PropertyObject    = (@{virtualApplications = $webAppVirtualApp })
            ErrorAction       = "Stop"
            Force             = $True
        }

        Set-AzResource @setParams | Out-Null

        Write-Information -MessageData "Successfully updated WebApp Virtual Application settings!"
    } else {
        Write-Information -MessageData "No Virtual Application to be added!"
    }
} catch {
    $scriptError = $_.Exception
    $scriptError = $scriptError -split "\n"
    Write-Error "$scriptError"
    exit 1
}
